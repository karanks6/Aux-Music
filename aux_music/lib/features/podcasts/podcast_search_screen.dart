import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/router/app_router.dart';
import '../../core/providers/podcast_providers.dart';
import '../../core/playback/playback_providers.dart';
import '../../data/models/track.dart';

final _podcastSearchQueryProvider = StateProvider<String>((ref) => '');

final podcastSearchProvider = FutureProvider.autoDispose<List<Track>>((ref) async {
  final query = ref.watch(_podcastSearchQueryProvider);
  if (query.trim().isEmpty) return [];

  // Debounce logic
  await Future.delayed(const Duration(milliseconds: 500));
  if (ref.state is AsyncLoading) return []; // In case it gets cancelled

  final repo = ref.read(podcastRepositoryProvider);
  return repo.searchYoutubePodcasts(query.trim());
});

class PodcastSearchScreen extends ConsumerStatefulWidget {
  const PodcastSearchScreen({super.key});

  @override
  ConsumerState<PodcastSearchScreen> createState() => _PodcastSearchScreenState();
}

class _PodcastSearchScreenState extends ConsumerState<PodcastSearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(podcastSearchProvider);

    return Scaffold(
      backgroundColor: AuxColors.ink,
      appBar: AppBar(
        backgroundColor: AuxColors.ink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AuxColors.paper),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          style: AuxTypography.body.copyWith(color: AuxColors.paper),
          decoration: InputDecoration(
            hintText: 'Search Podcasts on YouTube...',
            hintStyle: AuxTypography.body.copyWith(color: AuxColors.paperMuted),
            border: InputBorder.none,
          ),
          onChanged: (val) {
            ref.read(_podcastSearchQueryProvider.notifier).state = val;
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: AuxColors.paperMuted),
              onPressed: () {
                _searchController.clear();
                ref.read(_podcastSearchQueryProvider.notifier).state = '';
                _focusNode.requestFocus();
              },
            ),
        ],
      ),
      body: _searchController.text.isEmpty
          ? Center(
              child: Text(
                'Search for podcast episodes.',
                style: AuxTypography.body.copyWith(color: AuxColors.paperMuted),
              ),
            )
          : searchResults.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AuxColors.ember),
              ),
              error: (e, st) => Center(
                child: Text(
                  'Search failed.\n$e',
                  style: AuxTypography.body.copyWith(color: AuxColors.paperMuted),
                  textAlign: TextAlign.center,
                ),
              ),
              data: (tracks) {
                if (tracks.isEmpty) {
                  return Center(
                    child: Text(
                      'No podcasts found.',
                      style: AuxTypography.body.copyWith(color: AuxColors.paperMuted),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: AuxSpacing.md),
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: AuxSpacing.lg, vertical: AuxSpacing.xs),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(AuxSpacing.sm),
                        child: track.artworkUrl != null
                            ? Image.network(
                                track.artworkUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.podcasts_rounded, size: 50, color: Colors.white54),
                              )
                            : const Icon(Icons.podcasts_rounded, size: 50, color: Colors.white54),
                      ),
                      title: Text(
                        track.title,
                        style: AuxTypography.bodySemiBold.copyWith(color: AuxColors.paper),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        track.artistName,
                        style: AuxTypography.caption.copyWith(color: AuxColors.paperMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        final handler = ref.read(audioHandlerProvider);
                        handler.playTracks(tracks, startIndex: index);
                        context.push(AppRoutes.nowPlaying);
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
