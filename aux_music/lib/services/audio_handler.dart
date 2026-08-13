import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../../data/models/track.dart';
import '../../data/models/license_type.dart';
import '../../data/adapters/adapter_aggregator.dart';
import '../../data/repositories/library_repository.dart';
import '../core/proxy/local_audio_proxy.dart';
import '../core/proxy/lazy_audio_source.dart';
import 'dart:io';
import 'pass_the_aux_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The central AudioHandler — bridges just_audio with audio_service for
/// lock-screen controls, notification, and background playback.
///
/// Responsibilities:
/// - Manages a ConcatenatingAudioSource queue (gapless playback)
/// - Resolves stream URLs lazily just before playback
/// - Exposes playback state to the rest of the app via streams
/// - Implements the audio_service protocol (MediaItem, controls, seekbar)
class AuxAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  late final AndroidEqualizer _equalizer;
  late final AudioPlayer _player;

  final ProviderContainer _ref;
  final MusicAdapterAggregator _aggregator;
  final LibraryRepository _library;

  AuxAudioHandler(this._ref, this._aggregator, this._library) {
    _equalizer = AndroidEqualizer();
    _player = AudioPlayer(
      audioLoadConfiguration: const AudioLoadConfiguration(
        androidLoadControl: AndroidLoadControl(
          minBufferDuration: Duration(seconds: 30),
          maxBufferDuration: Duration(seconds: 90),
          prioritizeTimeOverSizeThresholds: true,
        ),
      ),
      audioPipeline: AudioPipeline(androidAudioEffects: [_equalizer]),
      useProxyForRequestHeaders: false, // Bypass just_audio's buggy internal proxy
    );
    _init();
  }
  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(
    children: [],
    useLazyPreparation: true,
  );

  // ── Public streams ────────────────────────────────────────────────

  /// Combined stream of playback position, buffered position, and duration.
  Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (position, buffered, duration) => PositionData(
          position: position,
          buffered: buffered,
          duration: duration ?? Duration.zero,
        ),
      );

  // ── Initialization ────────────────────────────────────────────────

  bool _isFetchingUpNext = false;

  Future<void> _init() async {
    // Start the local Dart audio proxy to bypass YouTube 403s safely
    await LocalAudioProxy().start();

    // Forward player state → audio_service playbackState
    _player.playbackEventStream.map(_transformEvent).listen((state) {
      playbackState.add(state);
    });

    // Forward player's current index → audio_service mediaItem
    _player.currentIndexStream.listen((index) async {
      print('[AudioHandler] currentIndexStream emitted: $index, queue length: ${queue.value.length}');
      if (index != null && index < queue.value.length) {
        // Only update mediaItem if we aren't currently overriding it for loading state
        if (!_isLoadingStream) {
          print('[AudioHandler] Setting mediaItem to ${queue.value[index].title}');
          mediaItem.add(queue.value[index]);
        }
        
        // Infinite Radio: Fetch UpNext when approaching end of queue
        if (index >= queue.value.length - 3 && !_isFetchingUpNext) {
          final inAux = _inAuxSession();
          if (!inAux) {
            _isFetchingUpNext = true;
            try {
              final currentTrackId = queue.value[index].extras?['trackId'] as String?;
              if (currentTrackId != null && currentTrackId.startsWith('youtube_music:')) {
                 final tracks = await _aggregator.getUpNext(currentTrackId);
                 if (tracks.isNotEmpty) {
                   // Append tracks to the queue, avoiding duplicates if possible
                   final q = queue.value;
                   final existingIds = q.map((i) => i.extras?['trackId'] as String?).toSet();
                   final newTracks = tracks.where((t) => !existingIds.contains(t.id)).toList();
                   if (newTracks.isNotEmpty) {
                     final newMediaItems = newTracks.map((t) => t.toMediaItem()).toList();
                     final currentQ = List<MediaItem>.from(queue.value)..addAll(newMediaItems);
                     queue.add(currentQ);
                     
                     for (final item in newMediaItems) {
                       await _playlist.add(_createAudioSource(item));
                     }
                     print('[AudioHandler] Infinite Radio: Appended ${newTracks.length} tracks to queue');
                   }
                 }
              }
            } catch (e) {
              print('[AudioHandler] Infinite Radio fetch failed: $e');
            } finally {
              _isFetchingUpNext = false;
            }
          }
        }
      } else {
        print('[AudioHandler] index is null or out of bounds');
      }
    });

    // Handle playback completion
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        stop();
      }
    });

    try {
      await _player.setAudioSource(_playlist, preload: false);
    } catch (_) {
      // Empty playlist on init — ok
    }

    // Sync state to PassTheAux whenever these change (immediate events)
    queue.listen((_) => _syncToPassTheAux());
    mediaItem.listen((_) => _syncToPassTheAux());
    _player.playingStream.listen((_) => _syncToPassTheAux());

    // Bug Fix #4: Periodic host sync every 5 seconds to correct guest position drift.
    // State-change listeners alone are not enough — guests need fresh position timestamps.
    Timer.periodic(const Duration(seconds: 5), (_) => _syncToPassTheAux());

    // Listen to PassTheAuxState to mirror Host playback if Sync Mode is on
    final passTheAuxNotifier = _ref.read(passTheAuxProvider.notifier);

    passTheAuxNotifier.onGuestAddedTrack.listen((track) async {
      if (_ref.read(passTheAuxProvider).isHost) {
        final wasEmpty = queue.value.isEmpty;
        await addToQueue(track);
        if (wasEmpty) {
          await skipToQueueItem(0);
        }
      }
    });

    _ref.listen<PassTheAuxState>(passTheAuxProvider, (previous, next) {
      // Clear the host's queue when they create a new room to ensure a fresh empty queue
      if (next.isHost && next.roomId != null && previous?.roomId == null) {
        updateQueue([]);
        stop();
      }

      if (!next.isHost && next.roomId != null && next.isSyncModeEnabled) {
        // 1. Sync Track Changes
        final currentTrackId = mediaItem.valueOrNull?.id;
        final nextTrackId = next.nowPlaying?.id;

        if (nextTrackId != null && currentTrackId != nextTrackId) {
          _guestForcePlay(next.nowPlaying!, next.isPlaying, next.position, next.timestamp);
        }

        // 2. Sync Play/Pause state (only when same track is already loaded)
        if (currentTrackId == nextTrackId) {
          if (next.isPlaying != _player.playing) {
            if (next.isPlaying) {
              _player.play();
            } else {
              _player.pause();
            }
          }

          // 3. Sync position if drift > 2 seconds
          if (next.position != null && next.timestamp != null) {
            final now = DateTime.now().millisecondsSinceEpoch;
            final elapsed = now - next.timestamp!;
            final expectedPositionMs = next.position! + elapsed;
            final localPositionMs = _player.position.inMilliseconds;
            final diff = (expectedPositionMs - localPositionMs).abs();

            if (diff > 2000) {
              _player.seek(Duration(milliseconds: expectedPositionMs));
            }
          }
        }
      }
    });
  }

  String? _currentlyForcingTrackId;

  /// Bug Fix #5: Secure guest force play against concurrent calls and race conditions
  Future<void> _guestForcePlay(
    Track track,
    bool shouldPlay,
    int? positionMs,
    int? timestamp,
  ) async {
    if (_currentlyForcingTrackId == track.id) return;
    _currentlyForcingTrackId = track.id;
    
    try {
      final item = track.toMediaItem();
      await updateQueue([item]);

      // Seek to 0 to trigger loading
      await _player.seek(Duration.zero, index: 0);

      // Now fetch the LATEST state to decide whether to play and where to seek
      final latestState = _ref.read(passTheAuxProvider);
      
      if (latestState.position != null && latestState.timestamp != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final elapsed = now - latestState.timestamp!;
        final expectedPositionMs = latestState.position! + elapsed + 100;
        try {
          await _player.seek(Duration(milliseconds: expectedPositionMs));
        } catch (_) {}
      }

      if (latestState.isPlaying) {
        await _player.play();
      } else {
        await _player.pause();
      }
    } finally {
      if (_currentlyForcingTrackId == track.id) {
        _currentlyForcingTrackId = null;
      }
    }
  }

  void _syncToPassTheAux() {
    try {
      final auxState = _ref.read(passTheAuxProvider);
      if (auxState.isHost) {
        _ref.read(passTheAuxProvider.notifier).hostSyncState(
          nowPlaying: mediaItem.valueOrNull?.toTrack(),
          isPlaying: _player.playing,
          queue: queue.value.map((m) => m.toTrack()).toList(),
          position: _player.position.inMilliseconds,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
      }
    } catch (_) {}
  }

  // ── Queue management ──────────────────────────────────────────────

  bool _inAuxSession() {
    try {
      final state = _ref.read(passTheAuxProvider);
      return state.roomId != null;
    } catch (_) {
      return false;
    }
  }

  bool _isGuest() {
    try {
      final state = _ref.read(passTheAuxProvider);
      return state.roomId != null && !state.isHost;
    } catch (_) {
      return false;
    }
  }

  void _guestAddTrack(Track track) {
    try {
      _ref.read(passTheAuxProvider.notifier).addTrack(track);
    } catch (_) {}
  }

  /// Play a single track immediately (replaces queue).
  Future<void> playTrack(Track track) async {
    try {
      final auxState = _ref.read(passTheAuxProvider);
      if (auxState.roomId != null) {
        if (auxState.isHost) {
          final q = queue.value;
          if (q.any((m) => m.id == track.id || m.extras?['trackId'] == track.id)) {
            _ref.read(passTheAuxProvider.notifier).notifyMessage('Track is already in the queue');
            return;
          }
          final wasEmpty = q.isEmpty;
          await addToQueue(track);
          if (wasEmpty) {
            await skipToQueueItem(0);
          }
          _ref.read(passTheAuxProvider.notifier).notifyMessage('Added "${track.title}" to the queue!');
        } else {
          if (auxState.sharedQueue.any((t) => t.id == track.id)) {
            _ref.read(passTheAuxProvider.notifier).notifyMessage('Track is already in the queue');
            return;
          }
          _ref.read(passTheAuxProvider.notifier).addTrack(track);
        }
        return;
      }
    } catch (_) {}

    final mediaItem = track.toMediaItem();
    await updateQueue([mediaItem]);
    await _resolveAndPlay(track, index: 0);
  }

  /// Play a list of tracks starting at [startIndex].
  Future<void> playTracks(List<Track> tracks, {int startIndex = 0}) async {
    try {
      final auxState = _ref.read(passTheAuxProvider);
      if (auxState.roomId != null) {
        final track = tracks[startIndex];
        if (auxState.isHost) {
          final q = queue.value;
          if (q.any((m) => m.id == track.id || m.extras?['trackId'] == track.id)) {
            _ref.read(passTheAuxProvider.notifier).notifyMessage('Track is already in the queue');
            return;
          }
          final wasEmpty = q.isEmpty;
          await addToQueue(track);
          if (wasEmpty) {
            await skipToQueueItem(0);
          }
          _ref.read(passTheAuxProvider.notifier).notifyMessage('Added "${track.title}" to the queue!');
        } else {
          if (auxState.sharedQueue.any((t) => t.id == track.id)) {
            _ref.read(passTheAuxProvider.notifier).notifyMessage('Track is already in the queue');
            return;
          }
          _ref.read(passTheAuxProvider.notifier).addTrack(track);
        }
        return;
      }
    } catch (_) {}

    await _player.pause(); // Pause immediately to prevent auto-skipping silent tracks
    final items = tracks.map((t) => t.toMediaItem()).toList();
    await _updateQueueWithIndex(items, initialIndex: startIndex);
    await _resolveAndPlay(tracks[startIndex], index: startIndex);
  }

  /// Add a track to the end of the queue.
  Future<void> addToQueue(Track track) async {
    if (_isGuest()) {
      _guestAddTrack(track);
      return;
    }
    final item = track.toMediaItem();
    await addQueueItem(item);
  }

  /// Add a track immediately after the current track.
  Future<void> playNext(Track track) async {
    if (_isGuest()) {
      _guestAddTrack(track);
      return;
    }
    final currentIndex = _player.currentIndex ?? -1;
    final item = track.toMediaItem();
    await insertQueueItem(currentIndex + 1, item);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _syncToPassTheAux();
  }

  @override
  Future<void> skipToNext() async {
    final q = queue.value;
    final nextIndex = (_player.currentIndex ?? -1) + 1;
    if (nextIndex < q.length) {
      if (!_isLoadingStream) {
        mediaItem.add(q[nextIndex]);
      }
      await _player.seek(Duration.zero, index: nextIndex);
      if (!_player.playing) {
        await _player.play();
      }
    }
  }

  @override
  Future<void> skipToPrevious() async {
    // If >3s in, restart track; otherwise go to previous
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else {
      final prevIndex = (_player.currentIndex ?? 1) - 1;
      final q = queue.value;
      if (prevIndex >= 0 && prevIndex < q.length) {
        if (!_isLoadingStream) {
          mediaItem.add(q[prevIndex]);
        }
        await _player.seek(Duration.zero, index: prevIndex);
        if (!_player.playing) {
          await _player.play();
        }
      }
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    final q = queue.value;
    if (index < q.length) {
      if (!_isLoadingStream) {
        mediaItem.add(q[index]);
      }
      await _player.seek(Duration.zero, index: index);
      if (!_player.playing) {
        await _player.play();
      }
    }
  }
  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode != AudioServiceShuffleMode.none;
    await _player.setShuffleModeEnabled(enabled);
    await super.setShuffleMode(shuffleMode);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    await _player.setLoopMode(_toLoopMode(repeatMode));
    await super.setRepeatMode(repeatMode);
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
    await super.setSpeed(speed);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  Future<void> setEqPreset(int presetIndex) async {
    try {
      final params = await _equalizer.parameters;
      final bands = params.bands;
      if (bands.isEmpty) return;

      // Ensure EQ is enabled
      if (!_equalizer.enabled) {
        await _equalizer.setEnabled(true);
      }

      final maxDecibels = params.maxDecibels;
      final minDecibels = params.minDecibels;
      
      // Default to Flat (all 0)
      List<double> gains = List.filled(bands.length, 0.0);
      
      // Equalizer presets scaled to device max/min decibels
      if (bands.length >= 5) {
        switch (presetIndex) {
          case 0: // flat
            gains = [0.0, 0.0, 0.0, 0.0, 0.0];
            break;
          case 1: // acoustic
            gains = [maxDecibels*0.6, maxDecibels*0.2, maxDecibels*0.3, maxDecibels*0.2, maxDecibels*0.4];
            break;
          case 2: // bassBoost
            gains = [maxDecibels, maxDecibels*0.7, 0.0, 0.0, 0.0];
            break;
          case 3: // classical
            gains = [maxDecibels*0.5, maxDecibels*0.4, minDecibels*0.2, maxDecibels*0.4, maxDecibels*0.5];
            break;
          case 4: // electronic
            gains = [maxDecibels*0.6, maxDecibels*0.4, minDecibels*0.1, maxDecibels*0.3, maxDecibels*0.6];
            break;
          case 5: // rock
            gains = [maxDecibels*0.7, maxDecibels*0.4, minDecibels*0.2, maxDecibels*0.4, maxDecibels*0.7];
            break;
          case 6: // vocal
            gains = [minDecibels*0.3, maxDecibels*0.2, maxDecibels*0.6, maxDecibels*0.4, minDecibels*0.2];
            break;
        }
      }

      for (int i = 0; i < bands.length; i++) {
        final gain = i < gains.length ? gains[i] : 0.0;
        await bands[i].setGain(gain);
      }
    } catch (e) {
      // ignore: avoid_print
      print('[AudioHandler] Failed to apply EQ preset: $e');
    }
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    await _updateQueueWithIndex(queue, initialIndex: 0);
  }

  Future<void> _updateQueueWithIndex(List<MediaItem> queueList, {int initialIndex = 0}) async {
    this.queue.add(queueList);
    if (initialIndex < queueList.length) {
      if (!_isLoadingStream) {
        mediaItem.add(queueList[initialIndex]);
      }
    }
    
    final audioSources = queueList.map((item) => _createAudioSource(item)).toList();
    
    _playlist = ConcatenatingAudioSource(
      children: audioSources,
      useLazyPreparation: true,
    );
    await _player.setAudioSource(_playlist, initialIndex: initialIndex);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    if (queue.value.isEmpty) {
      await _updateQueueWithIndex([mediaItem], initialIndex: 0);
    } else {
      final q = List<MediaItem>.from(queue.value)..add(mediaItem);
      queue.add(q);
      await _playlist.add(_createAudioSource(mediaItem));
    }
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    if (queue.value.isEmpty) {
      await _updateQueueWithIndex([mediaItem], initialIndex: 0);
    } else {
      final q = List<MediaItem>.from(queue.value)..insert(index, mediaItem);
      queue.add(q);
      await _playlist.insert(index, _createAudioSource(mediaItem));
    }
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    final q = List<MediaItem>.from(queue.value)..removeAt(index);
    queue.add(q);
    await _playlist.removeAt(index);
  }

  /// Custom method to reorder items in the queue
  Future<void> moveQueueItem(int currentIndex, int newIndex) async {
    final q = List<MediaItem>.from(queue.value);
    if (currentIndex < 0 || currentIndex >= q.length) return;
    if (newIndex < 0 || newIndex > q.length) return;
    
    // Adjust newIndex if we are moving downwards
    if (currentIndex < newIndex) {
      newIndex--;
    }
    
    final item = q.removeAt(currentIndex);
    q.insert(newIndex, item);
    queue.add(q);
    
    await _playlist.move(currentIndex, newIndex);
  }



  // ── Private helpers ───────────────────────────────────────────────

  bool _isLoadingStream = false;

  Future<void> _resolveAndPlay(Track track, {required int index}) async {
    await _player.seek(Duration.zero, index: index);
    await _player.play();
  }

  AudioSource _createAudioSource(MediaItem item) {
    final streamUrl = item.extras?['streamUrl'] as String?;
    if (streamUrl != null && streamUrl.isNotEmpty && streamUrl != 'data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQAAAAA=') {
      if (streamUrl.startsWith('/')) {
        return AudioSource.file(streamUrl, tag: item);
      } else if (streamUrl.startsWith('file://')) {
        return AudioSource.file(streamUrl.replaceFirst('file://', ''), tag: item);
      }
      return AudioSource.uri(
        Uri.parse(streamUrl),
        headers: const {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
        },
        tag: item,
      );
    }
    
    return LazyAudioSource(
      tag: item,
      headers: const {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
      },
      resolveUrl: () async {
        final trackId = item.extras?['trackId'] as String? ?? item.id;
        final download = await _library.getDownload(trackId);
        if (download != null && File(download.localPath).existsSync()) {
          return 'file://${download.localPath}';
        }
        
        if (trackId.startsWith('podcast:')) {
          final url = item.extras?['streamUrl'] as String? ?? item.extras?['sourceUrl'] as String? ?? '';
          if (url.isEmpty) throw Exception('Podcast missing stream URL');
          return url;
        }
        
        final result = await _aggregator.resolveStreamUrl(
          trackId,
          title: item.title,
          artistName: item.artist,
        );
        
        if (result.fallbackTrack != null) {
          final fallback = result.fallbackTrack!;
          final q = List<MediaItem>.from(queue.value);
          final idx = q.indexWhere((i) => i.id == item.id || i.extras?['trackId'] == trackId);
          if (idx != -1) {
            final oldItem = q[idx];
            final newExtras = Map<String, dynamic>.from(oldItem.extras ?? {})
              ..['streamUrl'] = result.url
              ..['trackId'] = fallback.id
              ..['sourceId'] = fallback.sourceId;
            final newItem = oldItem.copyWith(
              id: fallback.id,
              title: fallback.title,
              artist: fallback.artistName,
              album: fallback.albumName,
              artUri: fallback.artworkUrl != null ? Uri.parse(fallback.artworkUrl!) : oldItem.artUri,
              extras: newExtras,
            );
            q[idx] = newItem;
            queue.add(q);
            
            // If this is the currently playing item, update mediaItem so UI updates
            if (_player.currentIndex == idx) {
              mediaItem.add(newItem);
            }
          }
        }
        return result.url;
      },
    );
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    final playing = _player.playing;
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: _isLoadingStream
          ? AudioProcessingState.loading
          : {
              ProcessingState.idle: AudioProcessingState.idle,
              ProcessingState.loading: AudioProcessingState.loading,
              ProcessingState.buffering: AudioProcessingState.buffering,
              ProcessingState.ready: AudioProcessingState.ready,
              ProcessingState.completed: AudioProcessingState.completed,
            }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  LoopMode _toLoopMode(AudioServiceRepeatMode mode) => switch (mode) {
        AudioServiceRepeatMode.none => LoopMode.off,
        AudioServiceRepeatMode.one => LoopMode.one,
        AudioServiceRepeatMode.all || AudioServiceRepeatMode.group => LoopMode.all,
      };

  Future<void> dispose() async {
    await _player.dispose();
  }
}

/// Combined position / buffered / duration data for the seek bar.
class PositionData {
  const PositionData({
    required this.position,
    required this.buffered,
    required this.duration,
  });
  final Duration position;
  final Duration buffered;
  final Duration duration;
}

/// Extension to convert a Track to an audio_service MediaItem.
extension TrackToMediaItem on Track {
  MediaItem toMediaItem() => MediaItem(
        id: id,
        title: title,
        artist: artistName,
        album: albumName.isEmpty ? null : albumName,
        artUri: artworkUrl != null ? Uri.parse(artworkUrl!) : null,
        duration: durationMs > 0 ? Duration(milliseconds: durationMs) : null,
        extras: {
          'trackId': id,
          'sourceId': sourceId,
          'licenseType': licenseType.name,
          'attributionString': attributionString,
          'offlineAllowed': offlineAllowed,
          'streamUrl': streamUrl ?? '',
          'artistId': artistId,
          'albumId': albumId,
        },
      );
}

extension MediaItemToTrack on MediaItem {
  Track toTrack() {
    final licenseStr = extras?['licenseType'] as String? ?? 'unknown';
    return Track(
      id: extras?['trackId'] as String? ?? id,
      title: title,
      artistName: artist ?? 'Unknown Artist',
      albumName: album ?? '',
      artworkUrl: artUri?.toString(),
      durationMs: duration?.inMilliseconds ?? 0,
      sourceId: extras?['sourceId'] as String? ?? 'unknown',
      licenseType: LicenseType.values.firstWhere(
        (e) => e.name == licenseStr,
        orElse: () => LicenseType.unknown,
      ),
      attributionString: extras?['attributionString'] as String? ?? '',
      offlineAllowed: extras?['offlineAllowed'] as bool? ?? true,
      streamUrl: extras?['streamUrl'] as String?,
      artistId: extras?['artistId'] as String? ?? '',
      albumId: extras?['albumId'] as String? ?? '',
    );
  }
}
