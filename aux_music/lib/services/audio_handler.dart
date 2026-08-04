import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../../data/models/track.dart';
import '../../data/adapters/adapter_aggregator.dart';
import '../../data/repositories/library_repository.dart';
import '../core/proxy/local_audio_proxy.dart';
import '../core/proxy/youtube_stream_audio_source.dart';
import '../core/proxy/lazy_audio_source.dart';
import 'dart:io';
import 'dart:convert';

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

  AuxAudioHandler(this._aggregator, this._library) {
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

  final MusicAdapterAggregator _aggregator;
  final LibraryRepository _library;
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
      if (index != null && index < queue.value.length) {
        // Only update mediaItem if we aren't currently overriding it for loading state
        if (!_isLoadingStream) {
          mediaItem.add(queue.value[index]);
        }
        // Infinite Radio: Fetch UpNext when approaching end of queue
        if (index >= queue.value.length - 2 && !_isFetchingUpNext) {
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
  }

  // ── Queue management ──────────────────────────────────────────────

  /// Play a single track immediately (replaces queue).
  Future<void> playTrack(Track track) async {
    final mediaItem = track.toMediaItem();
    await updateQueue([mediaItem]);
    await _resolveAndPlay(track, index: 0);
  }

  /// Play a list of tracks starting at [startIndex].
  Future<void> playTracks(List<Track> tracks, {int startIndex = 0}) async {
    await _player.pause(); // Pause immediately to prevent auto-skipping silent tracks
    final items = tracks.map((t) => t.toMediaItem()).toList();
    await _updateQueueWithIndex(items, initialIndex: startIndex);
    await _resolveAndPlay(tracks[startIndex], index: startIndex);
  }

  /// Add a track to the end of the queue.
  Future<void> addToQueue(Track track) async {
    final item = track.toMediaItem();
    await addQueueItem(item);
  }

  /// Add a track immediately after the current track.
  Future<void> playNext(Track track) async {
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
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_player.hasNext) {
      final nextIndex = (_player.currentIndex ?? -1) + 1;
      final q = queue.value;
      if (nextIndex < q.length) {
        final nextTrackId = q[nextIndex].extras?['trackId'] as String?;
        if (nextTrackId != null) {
          await _player.seekToNext();
          return;
        }
      }
      await _player.seekToNext();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    // If >3s in, restart track; otherwise go to previous
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else if (_player.hasPrevious) {
      await _player.seekToPrevious();
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    final q = queue.value;
    if (index < q.length) {
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
    
    final audioSources = queueList.map((item) => _createAudioSource(item)).toList();
    
    _playlist = ConcatenatingAudioSource(
      children: audioSources,
      useLazyPreparation: true,
    );
    await _player.setAudioSource(_playlist, initialIndex: initialIndex);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    final q = List<MediaItem>.from(queue.value)..add(mediaItem);
    queue.add(q);
    await _playlist.add(_createAudioSource(mediaItem));
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    final q = List<MediaItem>.from(queue.value)..insert(index, mediaItem);
    queue.add(q);
    await _playlist.insert(index, _createAudioSource(mediaItem));
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

  void _setLoadingState(bool isLoading, {int? forceIndex}) {
    _isLoadingStream = isLoading;
    if (forceIndex != null && forceIndex < queue.value.length) {
      mediaItem.add(queue.value[forceIndex]);
    }
    playbackState.add(_transformEvent(_player.playbackEvent));
  }

  Future<void> _resolveAndPlay(Track track, {required int index}) async {
    await _player.seek(Duration.zero, index: index);
    await _player.play();
  }

  AudioSource _createAudioSource(MediaItem item) {
    final streamUrl = item.extras?['streamUrl'] as String?;
    if (streamUrl != null && streamUrl.isNotEmpty && streamUrl != 'data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQAAAAA=') {
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
