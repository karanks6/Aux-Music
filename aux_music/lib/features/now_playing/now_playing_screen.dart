import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/waveform_visualizer.dart';
import '../../core/playback/playback_providers.dart';
import '../../core/di/providers.dart';
import '../../core/providers/library_providers.dart';
import '../../services/audio_handler.dart';
import '../../services/download_manager.dart';
import '../../data/models/track.dart';
import '../../data/models/license_type.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';

class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> {
  bool _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) {
      return const SizedBox.shrink();
    }
    final mediaItem = ref.watch(currentMediaItemProvider).valueOrNull;
    final isPlaying = ref.watch(isPlayingProvider).valueOrNull ?? false;
    final positionData = ref.watch(positionDataProvider).valueOrNull;
    final repeatMode = ref.watch(repeatModeProvider);
    final shuffle = ref.watch(shuffleEnabledProvider);
    final reduceMotion = ref.watch(reduceMotionProvider);
    final handler = ref.read(audioHandlerProvider);

    // Dominant color from album art for the radial gradient background
    final artUrl = mediaItem?.artUri?.toString();

    return Dismissible(
      key: const Key('now_playing_screen_dismissible'),
      direction: DismissDirection.down,
      onDismissed: (_) {
        setState(() {
          _isDismissed = true;
        });
        if (context.canPop()) {
          context.pop();
        }
      },
      child: Scaffold(
        body: Container(
        decoration: BoxDecoration(
          gradient: AuxColors.nowPlayingRadialGradient(AuxColors.ember),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Drag handle ────────────────────────────────────────
              const _DragHandle(),

              // ── Album art (Hero) ────────────────────────────────────
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AuxSpacing.xl,
                    vertical: AuxSpacing.md,
                  ),
                  child: _AlbumArt(
                    artUrl: artUrl,
                    isPlaying: isPlaying,
                    reduceMotion: reduceMotion,
                  ),
                ),
              ),

              // ── Track info + like ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.xl),
                child: _TrackInfo(mediaItem: mediaItem),
              ),

              const SizedBox(height: AuxSpacing.md),

              // ── Seek bar + time + waveform ─────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.xl),
                child: _SeekBar(
                  positionData: positionData,
                  handler: handler,
                  mediaItem: mediaItem,
                ),
              ),

              // ── Transport controls ──────────────────────────────────
              _TransportControls(
                isPlaying: isPlaying,
                repeatMode: repeatMode,
                shuffle: shuffle,
                handler: handler,
                ref: ref,
              ),

              const SizedBox(height: AuxSpacing.md),

              // ── Extra controls (Volume, EQ, Sleep Timer) ─────────────
              _ExtraControls(handler: handler, ref: ref, mediaItem: mediaItem),

              const SizedBox(height: AuxSpacing.md),

              // ── Attribution strip (spec §4.1: always visible) ───────
              if (mediaItem != null)
                _AttributionStrip(mediaItem: mediaItem),

              const SizedBox(height: AuxSpacing.xl),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

// ── Subwidgets ─────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AuxSpacing.lg),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AuxColors.paperMuted.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _AlbumArt extends ConsumerStatefulWidget {
  const _AlbumArt({
    required this.artUrl,
    required this.isPlaying,
    required this.reduceMotion,
  });
  final String? artUrl;
  final bool isPlaying;
  final bool reduceMotion;

  @override
  ConsumerState<_AlbumArt> createState() => _AlbumArtState();
}

class _AlbumArtState extends ConsumerState<_AlbumArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.isPlaying && !widget.reduceMotion) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_AlbumArt old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying && !widget.reduceMotion) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.animateTo(0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) => Transform.scale(
          scale: widget.reduceMotion ? 1.0 : _pulseAnim.value,
          child: child,
        ),
        child: Hero(
          tag: 'now-playing-art',
          child: Container(
            decoration: BoxDecoration(
              color: AuxColors.inkRaised,
              borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
              boxShadow: [
                BoxShadow(
                  color: AuxColors.ember.withValues(alpha: 0.4),
                  blurRadius: 48,
                  spreadRadius: 8,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: widget.artUrl != null
                ? Image.network(
                    widget.artUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _ArtPlaceholder(),
                  )
                : const _ArtPlaceholder(),
          ),
        ),
      ),
    );
  }
}

class _ArtPlaceholder extends StatelessWidget {
  const _ArtPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.music_note_rounded,
      size: 80,
      color: AuxColors.paperMuted,
    );
  }
}

class _TrackInfo extends ConsumerWidget {
  const _TrackInfo({required this.mediaItem});
  final MediaItem? mediaItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackId = mediaItem?.extras?['trackId'] as String?;
    final isLiked = trackId != null 
        ? ref.watch(isTrackLikedProvider(trackId)).valueOrNull ?? false
        : false;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  final albumId = mediaItem?.extras?['albumId'] as String?;
                  if (albumId != null && albumId.isNotEmpty) {
                    // Close the Now Playing screen first
                    context.pop();
                    // Navigate to Album page
                    context.push('/album/$albumId');
                  }
                },
                child: Text(
                  mediaItem?.title ?? 'Nothing playing',
                  style: AuxTypography.display.copyWith(
                    color: AuxColors.paper,
                    fontSize: 22,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AuxSpacing.xs),
              GestureDetector(
                onTap: () {
                  final artistId = mediaItem?.extras?['artistId'] as String?;
                  if (artistId != null && artistId.isNotEmpty) {
                    // Close the Now Playing screen first
                    context.pop();
                    // Navigate to Artist page
                    context.push('/artist/$artistId');
                  }
                },
                child: Text(
                  mediaItem?.artist ?? 'Open a track to start listening',
                  style: AuxTypography.body.copyWith(
                    color: AuxColors.signalTeal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AuxSpacing.md),
        // Like button
        Semantics(
          label: isLiked ? 'Unlike this track' : 'Like this track',
          button: true,
          child: IconButton(
            icon: Icon(
              isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            ),
            color: isLiked ? AuxColors.danger : AuxColors.paperMuted,
            iconSize: 28,
            onPressed: () {
              if (mediaItem != null) {
                // Reconstruct a basic Track object from MediaItem for the repository
                final track = Track(
                  id: mediaItem!.extras?['trackId'] as String? ?? mediaItem!.id,
                  title: mediaItem!.title,
                  artistName: mediaItem!.artist ?? 'Unknown',
                  artistId: '',
                  albumName: mediaItem!.album ?? '',
                  albumId: '',
                  artworkUrl: mediaItem!.artUri?.toString(),
                  thumbnailUrl: mediaItem!.artUri?.toString(),
                  sourceId: mediaItem!.extras?['sourceId'] as String? ?? '',
                  licenseType: LicenseType.custom, // generic
                  attributionString: mediaItem!.extras?['attributionString'] as String? ?? '',
                  sourceUrl: mediaItem!.extras?['sourceUrl'] as String? ?? '',
                  durationMs: mediaItem!.duration?.inMilliseconds ?? 0,
                  offlineAllowed: mediaItem!.extras?['offlineAllowed'] as bool? ?? false,
                  streamUrl: mediaItem!.extras?['streamUrl'] as String?,
                );
                ref.read(libraryRepositoryProvider).toggleLikeTrack(track);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _SeekBar extends StatefulWidget {
  const _SeekBar({
    required this.positionData,
    required this.handler,
    required this.mediaItem,
  });
  final PositionData? positionData;
  final AuxAudioHandler handler;
  final MediaItem? mediaItem;

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  double? _draggingValue;

  @override
  Widget build(BuildContext context) {
    final position = widget.positionData?.position ?? Duration.zero;
    final duration = widget.positionData?.duration ?? Duration.zero;
    final durationMs = duration.inMilliseconds.toDouble();
    final posMs = position.inMilliseconds.toDouble();

    final progress = durationMs > 0
        ? ((_draggingValue ?? posMs) / durationMs).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        // Stacked waveform + slider
        Stack(
          alignment: Alignment.center,
          children: [
            // Waveform visualizer (background)
            if (widget.mediaItem != null)
              WaveformVisualizer(
                seed: widget.mediaItem!.id,
                progress: progress,
                height: 48,
              ),
            // Seek slider (on top)
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: AuxColors.ember,
                inactiveTrackColor: Colors.transparent,
                thumbColor: Colors.white,
                overlayColor: AuxColors.ember.withValues(alpha: 0.15),
              ),
              child: Slider(
                value: progress,
                onChangeStart: (v) =>
                    setState(() => _draggingValue = v * durationMs),
                onChanged: (v) =>
                    setState(() => _draggingValue = v * durationMs),
                onChangeEnd: (v) {
                  widget.handler
                      .seek(Duration(milliseconds: (v * durationMs).toInt()));
                  setState(() => _draggingValue = null);
                },
              ),
            ),
          ],
        ),
        // Time labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(
                Duration(
                  milliseconds:
                      (_draggingValue ?? posMs).toInt(),
                ),
              ),
              style: AuxTypography.tabularProgress
                  .copyWith(color: AuxColors.paperMuted),
            ),
            Text(
              _formatDuration(duration),
              style: AuxTypography.tabularProgress
                  .copyWith(color: AuxColors.paperMuted),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _TransportControls extends StatelessWidget {
  const _TransportControls({
    required this.isPlaying,
    required this.repeatMode,
    required this.shuffle,
    required this.handler,
    required this.ref,
  });
  final bool isPlaying;
  final RepeatMode repeatMode;
  final bool shuffle;
  final AuxAudioHandler handler;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AuxSpacing.lg,
        vertical: AuxSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Shuffle
          Semantics(
            label: shuffle ? 'Shuffle on' : 'Shuffle off',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.shuffle_rounded),
              color: shuffle ? AuxColors.signalTeal : AuxColors.paperMuted,
              iconSize: 28,
              onPressed: () {
                final newShuffle = !shuffle;
                ref.read(shuffleEnabledProvider.notifier).state = newShuffle;
                handler.setShuffleMode(newShuffle
                    ? AudioServiceShuffleMode.all
                    : AudioServiceShuffleMode.none);
              },
            ),
          ),
          // Previous
          Semantics(
            label: 'Previous track',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.skip_previous_rounded),
              color: AuxColors.paper,
              iconSize: 40,
              onPressed: handler.skipToPrevious,
            ),
          ),
          // Play/Pause FAB
          Semantics(
            label: isPlaying ? 'Pause' : 'Play',
            button: true,
            child: GestureDetector(
              onTap: isPlaying ? handler.pause : handler.play,
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AuxColors.ember,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
          // Next
          Semantics(
            label: 'Next track',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.skip_next_rounded),
              color: AuxColors.paper,
              iconSize: 40,
              onPressed: handler.skipToNext,
            ),
          ),
          // Repeat
          Semantics(
            label: switch (repeatMode) {
              RepeatMode.off => 'Repeat off',
              RepeatMode.one => 'Repeat one',
              RepeatMode.all => 'Repeat all',
            },
            button: true,
            child: IconButton(
              icon: Icon(switch (repeatMode) {
                RepeatMode.off => Icons.repeat_rounded,
                RepeatMode.one => Icons.repeat_one_rounded,
                RepeatMode.all => Icons.repeat_rounded,
              }),
              color: repeatMode == RepeatMode.off
                  ? AuxColors.paperMuted
                  : AuxColors.signalTeal,
              iconSize: 28,
              onPressed: () {
                final next = RepeatMode.values[
                    (repeatMode.index + 1) % RepeatMode.values.length];
                ref.read(repeatModeProvider.notifier).state = next;
                handler.setRepeatMode(switch (next) {
                  RepeatMode.off => AudioServiceRepeatMode.none,
                  RepeatMode.one => AudioServiceRepeatMode.one,
                  RepeatMode.all => AudioServiceRepeatMode.all,
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Attribution strip — always visible, one-tap to expand (spec §4.1)
class _AttributionStrip extends StatelessWidget {
  const _AttributionStrip({required this.mediaItem});
  final MediaItem mediaItem;

  @override
  Widget build(BuildContext context) {
    final attribution =
        mediaItem.extras?['attributionString'] as String? ?? '';
    if (attribution.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _showAttributionSheet(context, mediaItem),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.xl),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: AuxColors.paperMuted,
            ),
            const SizedBox(width: AuxSpacing.xs),
            Expanded(
              child: Text(
                attribution,
                style: AuxTypography.caption.copyWith(
                  color: AuxColors.paperMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: AuxColors.paperMuted,
            ),
          ],
        ),
      ),
    );
  }

  void _showAttributionSheet(BuildContext context, MediaItem item) {
    final attribution = item.extras?['attributionString'] as String? ?? '';
    final licenseType = item.extras?['licenseType'] as String? ?? '';
    final sourceUrl = item.extras?['sourceUrl'] as String? ?? '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AuxSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About this track',
                style: AuxTypography.titleMd
                    .copyWith(color: AuxColors.paper)),
            const SizedBox(height: AuxSpacing.lg),
            _InfoRow('Title', item.title),
            _InfoRow('Artist', item.artist ?? '—'),
            _InfoRow('Album', item.album ?? '—'),
            _InfoRow('License', licenseType),
            _InfoRow('Attribution', attribution),
            if (sourceUrl.isNotEmpty) _InfoRow('Source', sourceUrl),
            const SizedBox(height: AuxSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AuxSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: AuxTypography.captionMedium
                    .copyWith(color: AuxColors.paperMuted)),
          ),
          Expanded(
            child: Text(value,
                style: AuxTypography.body
                    .copyWith(color: AuxColors.paper)),
          ),
        ],
      ),
    );
  }
}

class _ExtraControls extends ConsumerWidget {
  const _ExtraControls({required this.handler, required this.ref, required this.mediaItem});
  final AuxAudioHandler handler;
  final WidgetRef ref;
  final MediaItem? mediaItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(volumeProvider);
    final eqPreset = ref.watch(eqPresetProvider);
    final sleepTimer = ref.watch(sleepTimerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.xl),
      child: Row(
        children: [
          Icon(
            volume == 0 ? Icons.volume_off_rounded : Icons.volume_down_rounded,
            color: AuxColors.paperMuted,
            size: 20,
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: AuxColors.paperMuted,
                inactiveTrackColor: AuxColors.hairline,
                thumbColor: AuxColors.paperMuted,
              ),
              child: Slider(
                value: volume,
                onChanged: (v) {
                  ref.read(volumeProvider.notifier).state = v;
                  handler.setVolume(v);
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.speaker_group_rounded),
            color: AuxColors.paperMuted,
            iconSize: 22,
            onPressed: () {
              context.push(AppRoutes.passTheAux);
            },
          ),
          IconButton(
            icon: const Icon(Icons.equalizer_rounded),
            color: eqPreset != EqPreset.flat
                ? AuxColors.signalTeal
                : AuxColors.paperMuted,
            iconSize: 22,
            onPressed: () => _showEqSheet(context, ref, eqPreset),
          ),
          Consumer(
            builder: (context, ref, child) {
              if (mediaItem == null) {
                return IconButton(
                  icon: const Icon(Icons.download_rounded),
                  color: AuxColors.paperMuted,
                  iconSize: 22,
                  onPressed: null,
                );
              }
              
              final trackId = mediaItem!.extras?['trackId'] as String? ?? mediaItem!.id;
              final downloadedFilesAsync = ref.watch(downloadedFilesProvider);
              final isDownloaded = downloadedFilesAsync.valueOrNull?.any((d) => d.trackId == trackId) ?? false;
              final downloadManager = ref.read(downloadManagerProvider);
              
              // We don't watch the download manager because it's not a notifier,
              // but we show the state when it finishes via the downloadedFilesProvider.
              
              return IconButton(
                icon: Icon(isDownloaded ? Icons.download_done_rounded : Icons.download_rounded),
                color: isDownloaded ? AuxColors.signalTeal : AuxColors.paperMuted,
                iconSize: 22,
                onPressed: isDownloaded ? null : () async {
                  try {
                    final track = Track(
                      id: trackId,
                      title: mediaItem!.title,
                      artistName: mediaItem!.artist ?? 'Unknown Artist',
                      artworkUrl: mediaItem!.artUri?.toString(),
                      sourceId: mediaItem!.extras?['sourceId'] as String? ?? '',
                      artistId: '',
                      albumName: mediaItem!.album ?? '',
                      albumId: '',
                      thumbnailUrl: mediaItem!.artUri?.toString(),
                      licenseType: LicenseType.unknown,
                      attributionString: mediaItem!.extras?['attributionString'] as String? ?? '',
                      sourceUrl: mediaItem!.extras?['sourceUrl'] as String? ?? '',
                      language: '',
                      durationMs: mediaItem!.duration?.inMilliseconds ?? 0,
                      playCount: 0,
                      offlineAllowed: mediaItem!.extras?['offlineAllowed'] as bool? ?? true,
                    );
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Downloading ${track.title}...'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    
                    await downloadManager.downloadTrack(track);
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Download complete'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Download failed: $e'),
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
          IconButton(
            icon: Icon(
              sleepTimer.isActive ? Icons.timer : Icons.timer_outlined,
            ),
            color: sleepTimer.isActive
                ? AuxColors.signalTeal
                : AuxColors.paperMuted,
            iconSize: 22,
            onPressed: () => _showSleepTimerSheet(context, ref, sleepTimer),
          ),
          IconButton(
            icon: const Icon(Icons.queue_music_rounded),
            color: AuxColors.paperMuted,
            iconSize: 22,
            onPressed: () {
              context.push('/queue');
            },
          ),
        ],
      ),
    );
  }

  void _showEqSheet(BuildContext context, WidgetRef ref, EqPreset initial) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (ctx) => Consumer(
        builder: (context, ref, child) {
          final current = ref.watch(eqPresetProvider);
          return Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Equalizer',
                    style: AuxTypography.titleMd.copyWith(color: AuxColors.paper)),
                const SizedBox(height: AuxSpacing.md),
                Wrap(
                  spacing: AuxSpacing.sm,
                  runSpacing: AuxSpacing.sm,
                  children: EqPreset.values.map((preset) {
                    final isSelected = preset == current;
                    return ChoiceChip(
                      label: Text(
                        preset.name.toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AuxColors.paper,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AuxColors.ember,
                      showCheckmark: false,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(eqPresetProvider.notifier).state = preset;
                          ref.read(audioHandlerProvider).setEqPreset(preset.index);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AuxSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSleepTimerSheet(
      BuildContext context, WidgetRef ref, SleepTimerState initial) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (ctx) => Consumer(
        builder: (context, ref, child) {
          final current = ref.watch(sleepTimerProvider);
          return Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sleep Timer',
                    style: AuxTypography.titleMd.copyWith(color: AuxColors.paper)),
                const SizedBox(height: AuxSpacing.lg),
                if (current.isActive) ...[
                  _SleepTimerCountdown(current),
                  const SizedBox(height: AuxSpacing.md),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(sleepTimerProvider.notifier).setTimer(const SleepTimerState());
                    },
                    child: const Text('Turn Off Timer'),
                  ),
                  const Divider(height: AuxSpacing.xl * 2),
                ],
                Wrap(
                  spacing: AuxSpacing.sm,
                  runSpacing: AuxSpacing.sm,
                  children: [
                    _TimerChip('5 min', 5, ref, ctx, current),
                    _TimerChip('10 min', 10, ref, ctx, current),
                    _TimerChip('15 min', 15, ref, ctx, current),
                    _TimerChip('30 min', 30, ref, ctx, current),
                    _TimerChip('45 min', 45, ref, ctx, current),
                    _TimerChip('60 min', 60, ref, ctx, current),
                    ChoiceChip(
                      label: Text(
                        'End of Track',
                        style: TextStyle(
                          color: current.atEndOfTrack ? Colors.white : AuxColors.paper,
                          fontWeight: current.atEndOfTrack ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                      selected: current.atEndOfTrack,
                      selectedColor: AuxColors.ember,
                      showCheckmark: false,
                      onSelected: (_) {
                        ref.read(sleepTimerProvider.notifier).setTimer(
                            const SleepTimerState(atEndOfTrack: true));
                      },
                    ),
                    ActionChip(
                      label: Text(
                        'Custom',
                        style: const TextStyle(
                          color: AuxColors.paper,
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: Colors.transparent,
                      shape: const StadiumBorder(
                        side: BorderSide(color: AuxColors.paperMuted),
                      ),
                      onPressed: () {
                        _showCustomTimerDialog(context, ref);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AuxSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showCustomTimerDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AuxColors.inkRaised,
        title: Text('Custom Sleep Timer', style: AuxTypography.titleMd.copyWith(color: AuxColors.paper)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AuxColors.paper),
          decoration: const InputDecoration(
            labelText: 'Minutes',
            labelStyle: TextStyle(color: AuxColors.paperMuted),
            suffixText: 'min',
            suffixStyle: TextStyle(color: AuxColors.paperMuted),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AuxColors.paperMuted)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AuxColors.ember)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AuxColors.paperMuted)),
          ),
          TextButton(
            onPressed: () {
              final minutes = int.tryParse(controller.text);
              if (minutes != null && minutes > 0) {
                ref.read(sleepTimerProvider.notifier).setTimer(SleepTimerState(
                  endsAt: DateTime.now().add(Duration(minutes: minutes)),
                  originalMinutes: minutes,
                ));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Set', style: TextStyle(color: AuxColors.ember)),
          ),
        ],
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  const _TimerChip(this.label, this.minutes, this.ref, this.ctx, this.currentState);
  final String label;
  final int minutes;
  final WidgetRef ref;
  final BuildContext ctx;
  final SleepTimerState currentState;

  @override
  Widget build(BuildContext context) {
    final isSelected = currentState.originalMinutes == minutes;
    
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AuxColors.paper,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      selectedColor: AuxColors.ember,
      showCheckmark: false,
      onSelected: (_) {
        ref.read(sleepTimerProvider.notifier).setTimer(SleepTimerState(
          endsAt: DateTime.now().add(Duration(minutes: minutes)),
          originalMinutes: minutes,
        ));
      },
    );
  }
}

class _SleepTimerCountdown extends StatelessWidget {
  const _SleepTimerCountdown(this.state);
  final SleepTimerState state;

  @override
  Widget build(BuildContext context) {
    if (state.atEndOfTrack) {
      return Text('Timer set for End of Track',
          style: AuxTypography.body.copyWith(color: AuxColors.signalTeal));
    }
    
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final remaining = state.remaining;
        if (remaining == null || remaining.isNegative) {
          return const SizedBox.shrink();
        }
        final minutes = remaining.inMinutes.toString().padLeft(2, '0');
        final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
        return Text(
          'Timer stops in $minutes:$seconds',
          style: AuxTypography.body.copyWith(color: AuxColors.signalTeal),
        );
      },
    );
  }
}
