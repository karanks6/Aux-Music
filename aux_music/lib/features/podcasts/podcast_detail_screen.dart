import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/router/app_router.dart';
import '../../core/playback/playback_providers.dart';
import '../../core/providers/podcast_providers.dart';
import '../../data/models/podcast.dart';

class PodcastDetailScreen extends ConsumerWidget {
  const PodcastDetailScreen({super.key, required this.podcast});
  final Podcast podcast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodes = ref.watch(podcastEpisodesProvider(podcast));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(podcast.title, style: AuxTypography.bodySemiBold),
      ),
      body: episodes.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AuxColors.ember)),
        error: (e, _) => Center(
          child: Text('Failed to load episodes', style: AuxTypography.body.copyWith(color: AuxColors.paperMuted)),
        ),
        data: (eps) {
          if (eps.isEmpty) {
            return Center(
              child: Text('No episodes found', style: AuxTypography.body.copyWith(color: AuxColors.paperMuted)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AuxSpacing.sm),
            itemCount: eps.length,
            itemBuilder: (context, index) {
              final ep = eps[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(AuxSpacing.sm),
                  child: Container(
                    width: AuxSpacing.artSm,
                    height: AuxSpacing.artSm,
                    color: AuxColors.inkRaised,
                    child: ep.artworkUrl != null
                        ? Image.network(
                            ep.artworkUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.podcasts_rounded, color: AuxColors.paperMuted),
                          )
                        : const Icon(Icons.podcasts_rounded, color: AuxColors.paperMuted),
                  ),
                ),
                title: Text(
                  ep.title,
                  style: AuxTypography.bodySemiBold.copyWith(color: AuxColors.paper),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${_formatDate(ep.publishedAt)} • ${_formatDuration(ep.durationMs)}',
                  style: AuxTypography.caption.copyWith(color: AuxColors.paperMuted),
                ),
                onTap: () {
                  final handler = ref.read(audioHandlerProvider);
                  // Convert episode to track
                  final track = ep.toTrack(podcastTitle: podcast.title, podcastAuthor: podcast.author);
                  handler.playTrack(track);
                  context.push(AppRoutes.nowPlaying);
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int ms) {
    if (ms == 0) return 'Unknown length';
    final minutes = ms ~/ 60000;
    if (minutes > 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '${hours}h ${mins}m';
    }
    return '${minutes}m';
  }
}
