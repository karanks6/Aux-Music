import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/di/providers.dart';
import '../../data/models/track.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/providers/library_providers.dart';
import '../../core/playback/playback_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounceTimer;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        if (_controller.text == _query) return;
        setState(() => _query = _controller.text);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(
      searchTracksProvider(SearchQuery(query: _query)),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AuxSpacing.lg, AuxSpacing.lg, AuxSpacing.lg, AuxSpacing.sm,
              ),
              child: TextField(
                controller: _controller,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Artists, tracks, moods, genres…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                          tooltip: 'Clear search',
                        )
                      : null,
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    ref.read(libraryRepositoryProvider).addRecentSearch(value.trim());
                  }
                },
              ),
            ),

            // ── Results / empty state ─────────────────────────────
            Expanded(
              child: _query.isEmpty
                  ? _EmptySearchState(
                      onTapSearch: (q) {
                        _controller.text = q;
                      },
                    )
                  : results.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: AuxColors.ember,
                        ),
                      ),
                      error: (e, _) => Center(
                        child: Text(
                          'No matches. Try an artist, mood, or genre instead.',
                          style: AuxTypography.body.copyWith(
                            color: context.colors.paperMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      data: (tracks) => tracks.isEmpty
                          ? Center(
                              child: Text(
                                'No matches. Try an artist, mood, or genre instead.',
                                style: AuxTypography.body.copyWith(
                                  color: context.colors.paperMuted,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : _SearchResults(tracks: tracks),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearchState extends ConsumerWidget {
  const _EmptySearchState({required this.onTapSearch});
  final Function(String) onTapSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentSearchesProvider).valueOrNull ?? [];
    const genres = [
      ('Electronic', AuxColors.signalTeal),
      ('Hip-Hop', AuxColors.ember),
      ('Classical', Color(0xFF8B7CF8)),
      ('Jazz', Color(0xFFFFBB45)),
      ('Rock', Color(0xFFFF6B6B)),
      ('Ambient', Color(0xFF4ECDC4)),
      ('Podcast', Color(0xFF60C8F5)),
      ('Audiobook', Color(0xFFD4A853)),
    ];

    return CustomScrollView(
      slivers: [
        if (recent.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AuxSpacing.lg, AuxSpacing.md, AuxSpacing.lg, AuxSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Searches', style: AuxTypography.titleMd.copyWith(color: context.colors.paper)),
                  TextButton(
                    onPressed: () {
                      ref.read(libraryRepositoryProvider).clearRecentSearches();
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final r = recent[index];
                return ListTile(
                  leading: Icon(Icons.history_rounded, color: context.colors.paperMuted),
                  title: Text(r, style: AuxTypography.body.copyWith(color: context.colors.paper)),
                  onTap: () => onTapSearch(r),
                );
              },
              childCount: recent.length,
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AuxSpacing.lg, AuxSpacing.xl, AuxSpacing.lg, AuxSpacing.sm),
            child: Text('Browse Genres', style: AuxTypography.titleMd.copyWith(color: context.colors.paper)),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.lg),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 80,
              crossAxisSpacing: AuxSpacing.sm,
              mainAxisSpacing: AuxSpacing.sm,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final genre = genres[i];
                return InkWell(
                  onTap: () => onTapSearch(genre.$1),
                  borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
                  child: Container(
                    decoration: BoxDecoration(
                      color: genre.$2.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
                      border: Border.all(color: genre.$2.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                      child: Text(
                        genre.$1,
                        style: AuxTypography.bodySemiBold.copyWith(color: genre.$2),
                      ),
                    ),
                  ),
                );
              },
              childCount: genres.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AuxSpacing.xxxl)),
      ],
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.tracks});
  final List<Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AuxSpacing.sm),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(AuxSpacing.sm),
            child: Container(
              width: AuxSpacing.artSm,
              height: AuxSpacing.artSm,
              color: context.colors.inkRaised,
              child: track.thumbnailUrl != null
                  ? Image.network(
                      track.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.music_note_rounded,
                        color: context.colors.paperMuted,
                      ),
                    )
                  : Icon(
                      Icons.music_note_rounded,
                      color: context.colors.paperMuted,
                    ),
            ),
          ),
          title: Text(
            track.title,
            style: AuxTypography.body.copyWith(color: context.colors.paper),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${track.artistName} · ${track.licenseType.displayLabel}',
            style: AuxTypography.caption.copyWith(color: context.colors.paperMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            track.durationDisplay,
            style: AuxTypography.tabularDuration.copyWith(
              color: context.colors.paperMuted,
            ),
          ),
          onTap: () {
            final handler = ref.read(audioHandlerProvider);
            final currentItem = handler.mediaItem.value;
            final currentTrackId = currentItem?.extras?['trackId'] as String? ?? currentItem?.id;
            
            if (currentTrackId != track.id) {
              handler.playTracks(tracks, startIndex: index);
            }
            context.push(AppRoutes.nowPlaying);
          },
        );
      },
    );
  }
}
