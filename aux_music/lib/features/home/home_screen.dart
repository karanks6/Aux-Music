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

// ── Trending providers for multiple shelves ────────────────────────────────

final _bollywoodProvider = FutureProvider<List<Track>>((ref) async {
  final aggregator = ref.read(aggregatorProvider);
  return aggregator.trending(genre: 'bollywood', limitPerSource: 25);
});

final _englishProvider = FutureProvider<List<Track>>((ref) async {
  final aggregator = ref.read(aggregatorProvider);
  return aggregator.trending(genre: 'english', limitPerSource: 25);
});

final _desiHipHopProvider = FutureProvider<List<Track>>((ref) async {
  final aggregator = ref.read(aggregatorProvider);
  return aggregator.trending(genre: 'desi hip-hop', limitPerSource: 25);
});

final _punjabiProvider = FutureProvider<List<Track>>((ref) async {
  final aggregator = ref.read(aggregatorProvider);
  return aggregator.trending(genre: 'punjabi', limitPerSource: 25);
});

final _globalPopProvider = FutureProvider<List<Track>>((ref) async {
  final aggregator = ref.read(aggregatorProvider);
  return aggregator.trending(genre: 'global pop', limitPerSource: 25);
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bollywood = ref.watch(_bollywoodProvider);
    final english = ref.watch(_englishProvider);
    final desiHipHop = ref.watch(_desiHipHopProvider);
    final punjabi = ref.watch(_punjabiProvider);
    final globalPop = ref.watch(_globalPopProvider);

    return Scaffold(
      body: RefreshIndicator(
        color: AuxColors.ember,
        backgroundColor: AuxColors.inkRaised,
        onRefresh: () async {
          ref.invalidate(_bollywoodProvider);
          ref.invalidate(_englishProvider);
          ref.invalidate(_desiHipHopProvider);
          ref.invalidate(_punjabiProvider);
          ref.invalidate(_globalPopProvider);
        },
        child: CustomScrollView(
          slivers: [
            // ── Header ───────────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              expandedHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(
                  left: AuxSpacing.lg,
                  bottom: AuxSpacing.md,
                ),
                title: Text(
                  'Aux',
                  style: AuxTypography.display.copyWith(
                    color: AuxColors.ember,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.0,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'Settings',
                  onPressed: () => context.push(AppRoutes.settings),
                ),
              ],
            ),

            // ── Multiple Shelves ────────────────────────────────────
            
            _buildCategorySection('Top Bollywood Songs', bollywood),
            _buildCategorySection('Trending English Hits', english),
            _buildCategorySection('Desi Hip-Hop', desiHipHop),
            _buildCategorySection('Top Punjabi Tracks', punjabi),
            _buildCategorySection('Global Pop', globalPop),

            const SliverToBoxAdapter(child: SizedBox(height: AuxSpacing.xxxl)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(String title, AsyncValue<List<Track>> asyncTracks) {
    return SliverToBoxAdapter(
      child: Column(
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
            child: asyncTracks.when(
              loading: () => _buildShimmerShelf(),
              error: (e, _) => Center(
                child: Text(
                  'Temporarily unavailable.',
                  style: AuxTypography.body.copyWith(color: AuxColors.paperMuted),
                  textAlign: TextAlign.center,
                ),
              ),
              data: (tracks) => _TrackShelf(tracks: tracks),
            ),
          ),
        ],
      ),
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
