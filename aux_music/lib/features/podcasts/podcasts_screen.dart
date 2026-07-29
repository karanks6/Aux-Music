import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/podcast_providers.dart';
import '../../core/di/providers.dart';
import '../../core/playback/playback_providers.dart';
import '../../data/models/track.dart';
import '../../data/models/podcast.dart';

// ── Podcast Category Providers ──────────────────────────────────────────────

final _techPodcastsProvider = FutureProvider<List<Podcast>>((ref) async {
  final repo = ref.read(podcastRepositoryProvider);
  final feeds = [
    'https://feeds.megaphone.fm/VMP5705694065', // Waveform
    'https://lexfridman.com/feed/podcast/', // Lex Fridman
    'https://feeds.megaphone.fm/vergecast', // Vergecast
  ];
  final futures = feeds.map((url) => repo.parseFeedUrl(url).then<Podcast?>((p) => p).catchError((_) => null));
  final results = await Future.wait(futures);
  return results.whereType<Podcast>().toList();
});

final _comedyPodcastsProvider = FutureProvider<List<Podcast>>((ref) async {
  final repo = ref.read(podcastRepositoryProvider);
  final feeds = [
    'https://feeds.simplecast.com/dHoohVNH', // Conan O'Brien
    'https://rss.art19.com/smartless', // SmartLess
    'https://wtfpod.libsyn.com/rss', // WTF with Marc Maron
  ];
  final futures = feeds.map((url) => repo.parseFeedUrl(url).then<Podcast?>((p) => p).catchError((_) => null));
  final results = await Future.wait(futures);
  return results.whereType<Podcast>().toList();
});

final _newsPodcastsProvider = FutureProvider<List<Podcast>>((ref) async {
  final repo = ref.read(podcastRepositoryProvider);
  final feeds = [
    'https://feeds.simplecast.com/54nAGcIl', // The Daily
    'https://feeds.npr.org/510318/podcast.xml', // Up First
    'https://podcasts.files.bbci.co.uk/p02nq0gn.rss', // Global News Podcast
  ];
  final futures = feeds.map((url) => repo.parseFeedUrl(url).then<Podcast?>((p) => p).catchError((_) => null));
  final results = await Future.wait(futures);
  return results.whereType<Podcast>().toList();
});

final _businessPodcastsProvider = FutureProvider<List<Podcast>>((ref) async {
  final repo = ref.read(podcastRepositoryProvider);
  final feeds = [
    'https://feeds.npr.org/510289/podcast.xml', // Planet Money
    'https://feeds.npr.org/510325/podcast.xml', // The Indicator
    'https://feeds.npr.org/510313/podcast.xml', // How I Built This
  ];
  final futures = feeds.map((url) => repo.parseFeedUrl(url).then<Podcast?>((p) => p).catchError((_) => null));
  final results = await Future.wait(futures);
  return results.whereType<Podcast>().toList();
});

class PodcastsScreen extends ConsumerWidget {
  const PodcastsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscribedPodcastsProvider);
    final tech = ref.watch(_techPodcastsProvider);
    final comedy = ref.watch(_comedyPodcastsProvider);
    final news = ref.watch(_newsPodcastsProvider);
    final business = ref.watch(_businessPodcastsProvider);

    return Scaffold(
      body: RefreshIndicator(
        color: AuxColors.ember,
        backgroundColor: AuxColors.inkRaised,
        onRefresh: () async {
          ref.invalidate(_techPodcastsProvider);
          ref.invalidate(_comedyPodcastsProvider);
          ref.invalidate(_newsPodcastsProvider);
          ref.invalidate(_businessPodcastsProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AuxSpacing.lg, AuxSpacing.xl, AuxSpacing.lg, AuxSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Podcasts',
                        style: AuxTypography.display.copyWith(
                          color: AuxColors.paper,
                          fontSize: 26,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add_rounded),
                        tooltip: 'Add via RSS',
                        onPressed: () => _showAddPodcastDialog(context, ref),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Local RSS subscriptions
            _buildLocalSubscriptionsSection(subscriptions, ref),

            // Online podcast categories
            _buildCategorySection('Technology', tech),
            _buildCategorySection('Comedy', comedy),
            _buildCategorySection('News & Politics', news),
            _buildCategorySection('Business & Finance', business),

            const SliverToBoxAdapter(child: SizedBox(height: AuxSpacing.xxxl)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(String title, AsyncValue<List<Podcast>> asyncPodcasts) {
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
            child: asyncPodcasts.when(
              loading: () => _buildShimmerShelf(),
              error: (e, _) => Center(
                child: Text(
                  'Temporarily unavailable.',
                  style: AuxTypography.body.copyWith(color: AuxColors.paperMuted),
                  textAlign: TextAlign.center,
                ),
              ),
              data: (podcasts) => _PodcastShelf(podcasts: podcasts),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalSubscriptionsSection(AsyncValue subscriptions, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: subscriptions.when(
        loading: () => const SizedBox(),
        error: (e, st) => const SizedBox(),
        data: (podcasts) {
          if (podcasts.isEmpty) return const SizedBox();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AuxSpacing.lg, AuxSpacing.xl, AuxSpacing.lg, AuxSpacing.md),
                child: Text('My Subscriptions', style: AuxTypography.titleMd.copyWith(color: AuxColors.paper)),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.lg),
                  itemCount: podcasts.length,
                  itemBuilder: (context, index) {
                    final pod = podcasts[index];
                    return GestureDetector(
                      onTap: () {
                        context.push(AppRoutes.podcastDetail.replaceFirst(':id', Uri.encodeComponent(pod.id)), extra: pod);
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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
                              child: pod.artworkUrl != null
                                  ? Image.network(
                                      pod.artworkUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Center(
                                        child: Icon(Icons.podcasts_rounded, color: Colors.white54, size: 40),
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(Icons.podcasts_rounded, color: Colors.white54, size: 40),
                                    ),
                            ),
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
                                    pod.title,
                                    style: AuxTypography.bodySemiBold.copyWith(color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    pod.author,
                                    style: AuxTypography.caption.copyWith(color: Colors.white70),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: AuxSpacing.xs,
                              right: AuxSpacing.xs,
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.white70),
                                onPressed: () {
                                  ref.read(podcastRepositoryProvider).unsubscribe(pod.id);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
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

  Widget _PodcastShelf({required List<Podcast> podcasts}) {
    if (podcasts.isEmpty) return const SizedBox();
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.lg),
      itemCount: podcasts.length,
      itemBuilder: (context, index) {
        final pod = podcasts[index];
        return GestureDetector(
          onTap: () {
            context.push(AppRoutes.podcastDetail.replaceFirst(':id', Uri.encodeComponent(pod.id)), extra: pod);
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
                  child: pod.artworkUrl != null
                      ? Image.network(
                          pod.artworkUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.podcasts_rounded, color: Colors.white54, size: 40),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.podcasts_rounded, color: Colors.white54, size: 40),
                        ),
                ),
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
                        pod.title,
                        style: AuxTypography.bodySemiBold.copyWith(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pod.author,
                        style: AuxTypography.caption.copyWith(color: Colors.white70),
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

  void _showAddPodcastDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AuxColors.ink,
        title: Text('Add Podcast', style: AuxTypography.titleMd.copyWith(color: AuxColors.paper)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'https://example.com/rss',
            hintStyle: TextStyle(color: AuxColors.paperMuted.withValues(alpha: 0.5)),
          ),
          style: const TextStyle(color: AuxColors.paper),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AuxColors.paperMuted)),
          ),
          TextButton(
            onPressed: () async {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                try {
                  final pod = await ref.read(podcastRepositoryProvider).parseFeedUrl(url);
                  await ref.read(podcastRepositoryProvider).subscribe(pod);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to parse feed: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Add', style: TextStyle(color: AuxColors.signalTeal)),
          ),
        ],
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
                              Icons.podcasts_rounded,
                              color: Colors.white54,
                              size: 40,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.podcasts_rounded,
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
