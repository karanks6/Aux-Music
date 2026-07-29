import 'dart:async';
import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/audio_handler.dart';
import '../di/providers.dart';
import '../providers/library_providers.dart';

// ── AudioHandler init ──────────────────────────────────────────────

/// Initialize and register the AudioHandler with audio_service.
/// Call once in main() before runApp.
Future<AuxAudioHandler> initAudioHandler(ProviderContainer ref) {
  return AudioService.init(
    builder: () => AuxAudioHandler(
      ref.read(aggregatorProvider),
      ref.read(libraryRepositoryProvider),
    ),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.aux_music.channel.audio',
      androidNotificationChannelName: 'Aux Music Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidShowNotificationBadge: true,
      notificationColor: Color(0xFFE8541A), // AuxColors.ember
    ),
  );
}

/// Global provider for the AudioHandler instance (initialized in main).
final audioHandlerProvider = Provider<AuxAudioHandler>((ref) {
  throw UnimplementedError('audioHandlerProvider must be overridden in main()');
});

// ── Playback State ─────────────────────────────────────────────────

/// Current playback state stream from audio_service.
final playbackStateProvider = StreamProvider<PlaybackState>((ref) {
  final handler = ref.read(audioHandlerProvider);
  return handler.playbackState;
});

/// Whether the player is currently playing.
final isPlayingProvider = StreamProvider<bool>((ref) {
  final handler = ref.read(audioHandlerProvider);
  return handler.playbackState.map((s) => s.playing);
});

/// Current media item (now playing track metadata).
final currentMediaItemProvider = StreamProvider<MediaItem?>((ref) {
  final handler = ref.read(audioHandlerProvider);
  return handler.mediaItem;
});

/// Position data (position + buffered + duration) for seek bar.
final positionDataProvider = StreamProvider<PositionData>((ref) {
  final handler = ref.read(audioHandlerProvider);
  return handler.positionDataStream;
});

/// The current queue as a list of MediaItems.
final queueProvider = StreamProvider<List<MediaItem>>((ref) {
  final handler = ref.read(audioHandlerProvider);
  return handler.queue;
});

/// The current index in the queue.
final queueIndexProvider = StreamProvider<int?>((ref) {
  final handler = ref.read(audioHandlerProvider);
  return handler.playbackState.map((s) => s.queueIndex);
});

// ── Shuffle & Repeat ──────────────────────────────────────────────

enum RepeatMode { off, one, all }

final repeatModeProvider = StateProvider<RepeatMode>((ref) => RepeatMode.off);
final shuffleEnabledProvider = StateProvider<bool>((ref) => false);

// ── Volume & Speed ────────────────────────────────────────────────

final volumeProvider = StateProvider<double>((ref) => 1.0);
final playbackSpeedProvider = StateProvider<double>((ref) => 1.0);

// ── EQ ────────────────────────────────────────────────────────────

enum EqPreset { flat, acoustic, bassBoost, classical, electronic, rock, vocal }

final eqPresetProvider = StateProvider<EqPreset>((ref) => EqPreset.flat);

// ── Sleep Timer ───────────────────────────────────────────────────

class SleepTimerState {
  const SleepTimerState({this.endsAt, this.atEndOfTrack = false, this.originalMinutes});
  final DateTime? endsAt;
  final bool atEndOfTrack;
  final int? originalMinutes;

  bool get isActive => endsAt != null || atEndOfTrack;
  Duration? get remaining => endsAt?.difference(DateTime.now());
}

class SleepTimerNotifier extends StateNotifier<SleepTimerState> {
  SleepTimerNotifier(this.ref) : super(const SleepTimerState()) {
    // Listen for track changes to detect end of track
    ref.listen(currentMediaItemProvider, (previous, next) {
      if (state.atEndOfTrack && previous?.valueOrNull != null && next.valueOrNull != null) {
        if (previous!.valueOrNull!.id != next.valueOrNull!.id) {
          _stopPlayback();
          state = const SleepTimerState();
        }
      }
    });
  }

  final Ref ref;
  Timer? _timer;

  void setTimer(SleepTimerState newState) {
    state = newState;
    _timer?.cancel();
    _timer = null;

    if (newState.endsAt != null) {
      final duration = newState.endsAt!.difference(DateTime.now());
      if (duration > Duration.zero) {
        _timer = Timer(duration, () {
          _stopPlayback();
          state = const SleepTimerState();
        });
      } else {
        _stopPlayback();
        state = const SleepTimerState();
      }
    }
  }

  void _stopPlayback() {
    try {
      ref.read(audioHandlerProvider).pause();
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final sleepTimerProvider =
    StateNotifierProvider<SleepTimerNotifier, SleepTimerState>((ref) => SleepTimerNotifier(ref));

// ── Type alias for ref parameter ─────────────────────────────────

typedef MusicAdapterAggregatorRef = ProviderContainer;
