import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../../data/models/track.dart';
import '../../data/adapters/adapter_aggregator.dart';
import '../../data/repositories/library_repository.dart';
import '../core/proxy/local_audio_proxy.dart';
import '../core/proxy/youtube_stream_audio_source.dart';
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
  ConcatenatingAudioSource _playlist =
      ConcatenatingAudioSource(children: []);

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

  Future<void> _init() async {
    // Start the local Dart audio proxy to bypass YouTube 403s safely
    await LocalAudioProxy().start();

    // Forward player state → audio_service playbackState
    _player.playbackEventStream.map(_transformEvent).listen((state) {
      playbackState.add(state);
    });

    // Forward player's current index → audio_service mediaItem
    _player.currentIndexStream.listen((index) {
      if (index != null && index < queue.value.length) {
        // Only update mediaItem if we aren't currently overriding it for loading state
        if (!_isLoadingStream) {
          mediaItem.add(queue.value[index]);
        }
        // Preload next track
        if (index + 1 < queue.value.length) {
          final nextTrackId = queue.value[index + 1].extras?['trackId'] as String?;
          if (nextTrackId != null) {
            _ensureStreamUrl(nextTrackId, index: index + 1);
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
          final wasPlaying = _player.playing;
          if (wasPlaying) await _player.pause();
          
          _setLoadingState(true, forceIndex: nextIndex);
          await _ensureStreamUrl(nextTrackId, index: nextIndex);
          await _player.seek(Duration.zero, index: nextIndex);
          _setLoadingState(false);
          
          if (wasPlaying) await _player.play();
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
      final trackId = q[index].extras?['trackId'] as String?;
      if (trackId != null) {
        await _player.pause();
        _setLoadingState(true, forceIndex: index);
        await _ensureStreamUrl(trackId, index: index);
      }
    }
    await _player.seek(Duration.zero, index: index);
    _setLoadingState(false);
    await _player.play();
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
    
    final audioSources = queueList.map((item) {
      final streamUrl = item.extras?['streamUrl'] as String?;
      // Valid 44-byte silent WAV file encoded as a data URI
      const placeholderUrl = 'data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQAAAAA=';
      final urlToParse = (streamUrl != null && streamUrl.isNotEmpty) ? streamUrl : placeholderUrl;
      
      if (urlToParse.startsWith('ytstream://')) {
        final uri = Uri.parse(urlToParse);
        final base64String = uri.queryParameters['url'] ?? '';
        final decodedUrl = utf8.decode(base64Url.decode(base64String));
        final length = int.parse(uri.queryParameters['length'] ?? '0');
        return YoutubeStreamAudioSource(
          url: decodedUrl,
          sourceLength: length,
          tag: item,
        );
      }
      
      return AudioSource.uri(
        Uri.parse(urlToParse),
        tag: item,
      );
    }).toList();
    
    _playlist = ConcatenatingAudioSource(children: audioSources);
    await _player.setAudioSource(_playlist, initialIndex: initialIndex);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    final q = List<MediaItem>.from(queue.value)..add(mediaItem);
    queue.add(q);
    final streamUrl = mediaItem.extras?['streamUrl'] as String?;
    const placeholderUrl = 'data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQAAAAA=';
    final urlToParse = (streamUrl != null && streamUrl.isNotEmpty) ? streamUrl : placeholderUrl;
    
    AudioSource source;
    if (urlToParse.startsWith('ytstream://')) {
      final uri = Uri.parse(urlToParse);
      final base64String = uri.queryParameters['url'] ?? '';
      final decodedUrl = utf8.decode(base64Url.decode(base64String));
      final length = int.parse(uri.queryParameters['length'] ?? '0');
      source = YoutubeStreamAudioSource(
        url: decodedUrl,
        sourceLength: length,
        tag: mediaItem,
      );
    } else {
      source = AudioSource.uri(
        Uri.parse(urlToParse),
        tag: mediaItem,
      );
    }
    await _playlist.add(source);
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    final q = List<MediaItem>.from(queue.value)..insert(index, mediaItem);
    queue.add(q);
    final streamUrl = mediaItem.extras?['streamUrl'] as String?;
    const placeholderUrl = 'data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQAAAAA=';
    final urlToParse = (streamUrl != null && streamUrl.isNotEmpty) ? streamUrl : placeholderUrl;
    
    AudioSource source;
    if (urlToParse.startsWith('ytstream://')) {
      final uri = Uri.parse(urlToParse);
      final base64String = uri.queryParameters['url'] ?? '';
      final decodedUrl = utf8.decode(base64Url.decode(base64String));
      final length = int.parse(uri.queryParameters['length'] ?? '0');
      source = YoutubeStreamAudioSource(
        url: decodedUrl,
        sourceLength: length,
        tag: mediaItem,
      );
    } else {
      source = AudioSource.uri(
        Uri.parse(urlToParse),
        tag: mediaItem,
      );
    }
    await _playlist.insert(index, source);
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    final q = List<MediaItem>.from(queue.value)..removeAt(index);
    queue.add(q);
    await _playlist.removeAt(index);
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
    _setLoadingState(true, forceIndex: index);
    await _ensureStreamUrl(track.id, index: index);
    await Future.delayed(const Duration(milliseconds: 150));
    await _player.seek(Duration.zero, index: index);
    _setLoadingState(false);
    await _player.play();
  }

  Future<void> _ensureStreamUrl(String trackId, {required int index}) async {
    try {
      final q1 = queue.value;
      if (index >= q1.length) return;
      final currentItem = q1[index];
      final currentStreamUrl = currentItem.extras?['streamUrl']?.toString();
      
      if (currentStreamUrl != null && currentStreamUrl.isNotEmpty) {
        if (currentStreamUrl.startsWith('ytstream://') && Uri.parse(currentStreamUrl).queryParameters['url'] == null) {
          // Found a corrupted old ytstream URL from cache (missing the query parameter). 
          // Force a fresh fetch by falling through!
          print('[AudioHandler] Ignoring corrupted cached stream URL for $trackId');
        } else {
          return; // Already resolved
        }
      }

      String url;
      final download = await _library.getDownload(trackId);
      if (download != null && File(download.localPath).existsSync()) {
        url = 'file://${download.localPath}';
      } else if (trackId.startsWith('podcast:')) {
        url = currentItem.extras?['streamUrl'] as String? ?? currentItem.extras?['sourceUrl'] as String? ?? '';
        if (url.isEmpty) throw Exception('Podcast missing stream URL');
      } else {
        url = await _aggregator.resolveStreamUrl(
          trackId,
          title: currentItem.title,
          artistName: currentItem.artist,
        );
      }
      
      final q2 = queue.value;
      if (index >= q2.length) return;

      final item = q2[index];
      final newExtras = Map<String, dynamic>.from(item.extras ?? {})
        ..['streamUrl'] = url;
      final updatedItem = item.copyWith(extras: newExtras);

      final newQueue = List<MediaItem>.from(q2);
      newQueue[index] = updatedItem;
      queue.add(newQueue);

      await _playlist.removeAt(index);
      
      AudioSource source;
      if (url.startsWith('ytstream://')) {
        final uri = Uri.parse(url);
        final base64String = uri.queryParameters['url'] ?? '';
        final decodedUrl = utf8.decode(base64Url.decode(base64String));
        final length = int.parse(uri.queryParameters['length'] ?? '0');
        source = YoutubeStreamAudioSource(
          url: decodedUrl,
          sourceLength: length,
          tag: updatedItem,
        );
      } else {
        source = AudioSource.uri(
          Uri.parse(url), 
          tag: updatedItem,
        );
      }
      
      await _playlist.insert(index, source);
    } catch (e) {
      // ignore: avoid_print
      print('[AudioHandler] Failed to resolve stream URL for $trackId: $e');
    }
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
        },
      );
}
