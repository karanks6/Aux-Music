import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/router/app_router.dart';
import '../../core/playback/playback_providers.dart';

/// The persistent mini-player, docked above the bottom navigation bar.
/// Visible whenever a track is loaded. Tapping navigates to NowPlayingScreen.
class MiniPlayerWidget extends ConsumerWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaItem = ref.watch(currentMediaItemProvider).valueOrNull;
    final isPlaying = ref.watch(isPlayingProvider).valueOrNull ?? false;
    final positionData = ref.watch(positionDataProvider).valueOrNull;
    final handler = ref.read(audioHandlerProvider);

    // Hide when nothing is loaded
    if (mediaItem == null) return const SizedBox.shrink();

    final artUrl = mediaItem.artUri?.toString();
    final durationMs = positionData?.duration.inMilliseconds ?? 1;
    final posMs = positionData?.position.inMilliseconds ?? 0;
    final progress =
        durationMs > 0 ? (posMs / durationMs).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.nowPlaying),
      child: Container(
        height: AuxSpacing.miniPlayerHeight,
        decoration: BoxDecoration(
          color: context.colors.inkRaised,
          border: Border(
            top: BorderSide(color: context.colors.hairline, width: 0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thin progress strip at the very top
            LinearProgressIndicator(
              value: progress,
              backgroundColor: context.colors.hairline,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AuxColors.ember),
              minHeight: 2,
            ),
            // Content row
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AuxSpacing.lg),
                child: Row(
                  children: [
                    // Album art (Hero tag matches NowPlayingScreen)
                    Hero(
                      tag: 'now-playing-art',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AuxSpacing.sm),
                        child: artUrl != null
                            ? Image.network(
                                artUrl,
                                width: AuxSpacing.artSm,
                                height: AuxSpacing.artSm,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const _ArtFallback(),
                              )
                            : const _ArtFallback(),
                      ),
                    ),
                    const SizedBox(width: AuxSpacing.md),
                    // Track title + artist
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mediaItem.title,
                            style: AuxTypography.bodySemiBold
                                .copyWith(color: context.colors.paper),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            mediaItem.artist ?? '',
                            style: AuxTypography.caption
                                .copyWith(color: context.colors.paperMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Play/Pause
                    Semantics(
                      label: isPlaying ? 'Pause' : 'Play',
                      button: true,
                      child: IconButton(
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        color: context.colors.paper,
                        iconSize: 32,
                        onPressed: isPlaying ? handler.pause : handler.play,
                      ),
                    ),
                    // Next
                    Semantics(
                      label: 'Next track',
                      button: true,
                      child: IconButton(
                        icon: const Icon(Icons.skip_next_rounded),
                        color: context.colors.paperMuted,
                        iconSize: 28,
                        onPressed: handler.skipToNext,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtFallback extends StatelessWidget {
  const _ArtFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AuxSpacing.artSm,
      height: AuxSpacing.artSm,
      color: context.colors.hairline,
      child: Icon(
        Icons.music_note_rounded,
        color: context.colors.paperMuted,
        size: 20,
      ),
    );
  }
}
