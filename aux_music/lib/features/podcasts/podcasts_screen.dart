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

class PodcastShelfData {
  final String title;
  final bool isEpisodes;
  final List<dynamic> items; // List<Podcast> or List<Track>
  
  PodcastShelfData({required this.title, required this.isEpisodes, required this.items});
}

final _podcastShelvesProvider = FutureProvider<List<PodcastShelfData>>((ref) async {
  final repo = ref.read(podcastRepositoryProvider);
  final shelves = <PodcastShelfData>[];
  final globalSeenUrls = <String>{};

  // Helper to fetch latest episodes for a query
  Future<List<Track>> getEpisodesForQuery(String query, {int limit = 4, int episodesPerPodcast = 1, bool useGlobalSeen = true}) async {
    final pods = await repo.searchPodcasts(query, limit: limit);
    final tracks = <Track>[];
    for (final pod in pods) {
      try {
        final eps = await repo.fetchEpisodes(pod);
        int added = 0;
        for (final ep in eps) {
          if (ep.streamUrl != null) {
            if (useGlobalSeen) {
              if (globalSeenUrls.contains(ep.streamUrl)) continue;
              globalSeenUrls.add(ep.streamUrl!);
            }
            tracks.add(ep.toTrack(podcastTitle: pod.title, podcastAuthor: pod.author));
            added++;
            if (added >= episodesPerPodcast) break;
          }
        }
      } catch (e) {
        // ignore
      }
    }
    return tracks;
  }

  // 1. Latest Hindi Content Episodes (Explicitly requested by user)
  final hindiNames = [
    'The Ranveer Show',
    'Figuring Out Raj Shamani',
    'WTF is Nikhil Kamath',
    'The BarberShop Shantanu',
    'Prakhar Ke Pravachan',
    'Maha Bharat Dhruv Rathee',
    'Bollywood Besharams',
    'Khandaan Bollywood',
    'Mahabharat Complete Saga',
    'Jaani Ki Kahaani',
    'Big Story Hindi',
  ];
  hindiNames.shuffle();
  
  // 2. Requested Popular Channels as individual categories
  final popularChannels = [
    'Prakhar Ke Pravachan',
    'The Ranveer Show',
    'Figuring Out Raj Shamani',
    'WTF is Nikhil Kamath',
    'The Joe Rogan Experience'
  ];

  // 3. Some Dynamic Podcast Album Shelves
  final categories = [
    {'title': 'Top Tech Podcasts', 'query': 'technology'},
    {'title': 'Comedy Specials', 'query': 'comedy'},
    {'title': 'News & Politics', 'query': 'news'},
    {'title': 'Science & History', 'query': 'science history'},
    {'title': 'True Crime', 'query': 'true crime'},
    {'title': 'Business & Finance', 'query': 'business'},
  ];
  categories.shuffle();
  final selectedCategories = categories.take(2).toList(); 
  
  // 4. More Single Episodes
  final epCategories = [
    {'title': 'Trending Tech Episodes', 'query': 'technology'},
    {'title': 'Popular Comedy Episodes', 'query': 'comedy'},
    {'title': 'New in Science', 'query': 'science'},
    {'title': 'Business Insights', 'query': 'startup business'},
  ];
  epCategories.shuffle();
  final selectedEpCategories = epCategories.take(1).toList(); 

  // Fire ALL requests concurrently!
  final results = await Future.wait([
    Future.wait(hindiNames.map((name) => getEpisodesForQuery(name, limit: 1, episodesPerPodcast: 2, useGlobalSeen: false))),
    Future.wait(popularChannels.map((channel) async {
      final eps = await getEpisodesForQuery(channel, limit: 1, episodesPerPodcast: 15, useGlobalSeen: false);
      return {'title': channel, 'eps': eps};
    })),
    Future.wait(selectedCategories.map((cat) async {
      final pods = await repo.searchPodcasts(cat['query']!, limit: 10);
      return {'title': cat['title']!, 'pods': pods};
    })),
    Future.wait(selectedEpCategories.map((cat) async {
      final eps = await getEpisodesForQuery(cat['query']!, limit: 6, useGlobalSeen: true);
      return {'title': cat['title']!, 'eps': eps};
    })),
  ]);

  // Process Hindi Results
  final hindiResults = results[0] as List<List<Track>>;
  final latestTracks = hindiResults.expand((eps) => eps).toList();
  if (latestTracks.isNotEmpty) {
    latestTracks.shuffle();
    shelves.add(PodcastShelfData(
      title: 'Latest Episodes (Hindi)',
      isEpisodes: true,
      items: latestTracks.take(20).toList(),
    ));
  }

  // Process Popular Channel Results
  final popularResults = results[1] as List<Map<String, dynamic>>;
  for (final res in popularResults) {
    final eps = res['eps'] as List<Track>;
    if (eps.isNotEmpty) {
      shelves.add(PodcastShelfData(title: res['title'] as String, isEpisodes: true, items: eps));
    }
  }

  // Process Album Results
  final albumResults = results[2] as List<Map<String, dynamic>>;
  for (final res in albumResults) {
    final pods = res['pods'] as List<Podcast>;
    if (pods.isNotEmpty) {
      shelves.add(PodcastShelfData(title: res['title'] as String, isEpisodes: false, items: pods));
    }
  }

  // Process Single Ep Results
  final singleEpResults = results[3] as List<Map<String, dynamic>>;
  for (final res in singleEpResults) {
    final eps = res['eps'] as List<Track>;
    if (eps.isNotEmpty) {
      shelves.add(PodcastShelfData(title: res['title'] as String, isEpisodes: true, items: eps));
    }
  }

  return shelves;
});

class PodcastsScreen extends ConsumerWidget {
  const PodcastsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscribedPodcastsProvider);
    final shelvesAsync = ref.watch(_podcastShelvesProvider);

    return Scaffold(
      body: RefreshIndicator(
        color: AuxColors.ember,
        backgroundColor: AuxColors.inkRaised,
        onRefresh: () async {
          ref.invalidate(_podcastShelvesProvider);
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

            // Dynamic Shelves
            shelvesAsync.when(
              loading: () => SliverToBoxAdapter(
                child: Column(
                  children: List.generate(3, (index) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AuxSpacing.lg),
                        child: Container(width: 150, height: 24, color: AuxColors.inkRaised),
                      ),
                      SizedBox(height: 200, child: _buildShimmerShelf()),
                    ],
                  )),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AuxSpacing.xl),
                  child: Center(
                    child: Text('Failed to load podcasts.\n$e', style: AuxTypography.body.copyWith(color: AuxColors.paperMuted), textAlign: TextAlign.center,),
                  ),
                ),
              ),
              data: (shelves) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final shelf = shelves[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AuxSpacing.lg, AuxSpacing.xl, AuxSpacing.lg, AuxSpacing.md,
                            ),
                            child: Text(
                              shelf.title,
                              style: AuxTypography.titleMd.copyWith(color: AuxColors.paper),
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child: shelf.isEpisodes
                                ? _TrackShelf(tracks: shelf.items as List<Track>)
                                : _PodcastShelf(podcasts: shelf.items as List<Podcast>),
                          ),
                        ],
                      );
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
    if (podcasts.isEmpty) {
      return Center(
        child: Text(
          'Temporarily unavailable.',
          style: AuxTypography.body.copyWith(color: AuxColors.paperMuted),
          textAlign: TextAlign.center,
        ),
      );
    }
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
