import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/di/providers.dart';
import '../../core/playback/playback_providers.dart';
import '../../data/models/track.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';

// ── Dynamic Recommendations Provider ──────────────────────────────────────

final _homeRecommendationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final aggregator = ref.read(aggregatorProvider);
  return aggregator.getHomeRecommendations();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(_homeRecommendationsProvider);

    return Scaffold(
      body: RefreshIndicator(
        color: AuxColors.ember,
        backgroundColor: AuxColors.inkRaised,
        onRefresh: () async {
          ref.invalidate(_homeRecommendationsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // ── Header ───────────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              toolbarHeight: 80,
              titleSpacing: AuxSpacing.lg,
              title: Text(
                'Aux',
                style: AuxTypography.display.copyWith(
                  color: AuxColors.ember,
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.0,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: AuxSpacing.sm),
                  child: IconButton(
                    iconSize: 30,
                    icon: const Icon(Icons.person_outline_rounded),
                    tooltip: 'My Profile',
                    onPressed: () => context.push(AppRoutes.profile),
                  ),
                ),
              ],
            ),

            // ── Dynamic Shelves ────────────────────────────────────
            
            recommendationsAsync.when(
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildShimmerSection(),
                  childCount: 3,
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AuxSpacing.xl),
                  child: Center(
                    child: Text(
                      'Temporarily unavailable.',
                      style: AuxTypography.body.copyWith(color: AuxColors.paperMuted),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              data: (shelves) {
                if (shelves.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AuxSpacing.xl),
                      child: Center(
                        child: Text(
                          'No recommendations found.',
                          style: AuxTypography.body.copyWith(color: AuxColors.paperMuted),
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final shelf = shelves[index];
                      final title = shelf['title'] as String;
                      final tracks = shelf['tracks'] as List<Track>;
                      return _buildCategorySection(title, tracks);
                    },
                    childCount: shelves.length,
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AuxSpacing.xxxl)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(String title, List<Track> tracks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AuxSpacing.lg, AuxSpacing.xl, AuxSpacing.lg, AuxSpacing.md,
          ),
          child: Text(
            title,
            style: AuxTypography.titleMd.copyWith(color: AuxColors.paper),
          ),
        ),
        SizedBox(
          height: 200,
          child: _TrackShelf(tracks: tracks),
        ),
      ],
    );
  }

  Widget _buildShimmerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AuxSpacing.lg, AuxSpacing.xl, AuxSpacing.lg, AuxSpacing.md,
          ),
          child: Container(
            width: 150,
            height: 24,
            decoration: BoxDecoration(
              color: AuxColors.inkRaised,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: _buildShimmerShelf(),
        ),
      ],
    );
  }

  Widget _buildShimmerShelf() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.lg),
      itemCount: 5,
      itemBuilder: (context, i) => Container(
        width: 160,
        height: 200,
        margin: const EdgeInsets.only(right: AuxSpacing.sm),
        decoration: BoxDecoration(
          color: AuxColors.inkRaised,
          borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
        ),
      ),
    );
  }
}

// ── Track Shelf ───────────────────────────────────────────────────────────

class _TrackShelf extends ConsumerWidget {
  const _TrackShelf({required this.tracks});
  final List<Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tracks.isEmpty) {
      return Center(
        child: Text(
          'Nothing here yet. Check back soon.',
          style: AuxTypography.body.copyWith(color: AuxColors.paperMuted),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.lg),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        return GestureDetector(
          onTap: () {
            final handler = ref.read(audioHandlerProvider);
            final currentItem = handler.mediaItem.value;
            final currentTrackId = currentItem?.extras?['trackId'] as String? ?? currentItem?.id;
            
            if (currentTrackId != track.id) {
              handler.playTracks(tracks, startIndex: index);
            }
            context.push(AppRoutes.nowPlaying);
          },
          child: Container(
            width: 160,
            margin: const EdgeInsets.only(right: AuxSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
              color: AuxColors.inkRaised,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Album Art
                ClipRRect(
                  borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
                  child: track.artworkUrl != null
                      ? Image.network(
                          track.artworkUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(
                              Icons.music_note_rounded,
                              color: Colors.white54,
                              size: 40,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.music_note_rounded,
                            color: Colors.white54,
                            size: 40,
                          ),
                        ),
                ),
                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.9),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                  padding: const EdgeInsets.all(AuxSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        track.title,
                        style: AuxTypography.bodySemiBold.copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        track.artistName,
                        style: AuxTypography.caption.copyWith(
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
