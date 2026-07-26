import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/providers/library_providers.dart';
import '../../core/widgets/track_list_tile.dart';
import '../../core/playback/playback_providers.dart';
import '../../services/download_manager.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../data/models/track.dart';
import '../../data/models/license_type.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  int _filterIndex = 0;
  bool _isGrid = false;
  final _filters = ['Liked Tracks', 'Playlists', 'Downloaded'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AuxSpacing.lg, AuxSpacing.xl, AuxSpacing.lg, AuxSpacing.sm,
              ),
              child: Row(
                children: [
                  Text(
                    'Your Library',
                    style: AuxTypography.display.copyWith(
                      color: AuxColors.paper,
                      fontSize: 26,
                    ),
                  ),
                  const Spacer(),
                  // Grid/list toggle
                  IconButton(
                    icon: Icon(
                      _isGrid ? Icons.list_rounded : Icons.grid_view_rounded,
                      color: AuxColors.paperMuted,
                    ),
                    onPressed: () => setState(() => _isGrid = !_isGrid),
                    tooltip: _isGrid ? 'List view' : 'Grid view',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_rounded,
                      color: AuxColors.ember,
                    ),
                    onPressed: () {
                      _showCreatePlaylistSheet(context, ref);
                    },
                    tooltip: 'Create playlist',
                  ),
                ],
              ),
            ),

            // ── Filter chips ──────────────────────────────────────
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.lg),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: AuxSpacing.xs),
                itemBuilder: (context, i) => FilterChip(
                  label: Text(_filters[i]),
                  selected: _filterIndex == i,
                  onSelected: (_) => setState(() => _filterIndex = i),
                  selectedColor: AuxColors.ember.withValues(alpha: 0.2),
                  checkmarkColor: AuxColors.ember,
                ),
              ),
            ),

            const SizedBox(height: AuxSpacing.md),

            // ── Content ───────────────────────────────────────────
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_filterIndex) {
      case 0:
        return _LikedTracksView();
      case 1:
        return _PlaylistsView(isGrid: _isGrid);
      case 2:
        return _DownloadedView();
      default:
        return const SizedBox.shrink();
    }
  }

  void _showCreatePlaylistSheet(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuxColors.inkRaised,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: AuxSpacing.lg,
          right: AuxSpacing.lg,
          top: AuxSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('New Playlist', style: AuxTypography.titleLg.copyWith(color: AuxColors.paper)),
            const SizedBox(height: AuxSpacing.lg),
            TextField(
              controller: controller,
              autofocus: true,
              style: AuxTypography.body.copyWith(color: AuxColors.paper),
              decoration: InputDecoration(
                hintText: 'Playlist name',
                hintStyle: const TextStyle(color: AuxColors.paperMuted),
                filled: true,
                fillColor: AuxColors.ink,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AuxSpacing.lg),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AuxColors.ember,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AuxSpacing.md),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AuxSpacing.radiusCard)),
              ),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  ref.read(libraryRepositoryProvider).createPlaylist(controller.text.trim());
                  context.pop();
                }
              },
              child: const Text('Create'),
            ),
            const SizedBox(height: AuxSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _LikedTracksView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTracks = ref.watch(likedTracksProvider);
    return asyncTracks.when(
      data: (tracks) {
        if (tracks.isEmpty) {
          return Center(
            child: Text('No liked tracks yet.', style: AuxTypography.body.copyWith(color: AuxColors.paperMuted)),
          );
        }
        return ListView.builder(
          itemCount: tracks.length,
          itemBuilder: (context, index) {
            final track = tracks[index];
            return TrackListTile(
              track: track,
              onTap: () {
                ref.read(audioHandlerProvider).playTracks(tracks, startIndex: index);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AuxColors.ember)),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AuxColors.danger))),
    );
  }
}

class _PlaylistsView extends ConsumerWidget {
  final bool isGrid;
  const _PlaylistsView({required this.isGrid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPlaylists = ref.watch(playlistsProvider);
    return asyncPlaylists.when(
      data: (playlists) {
        if (playlists.isEmpty) {
          return Center(
            child: Text('No playlists yet.', style: AuxTypography.body.copyWith(color: AuxColors.paperMuted)),
          );
        }
        if (isGrid) {
          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.lg),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AuxSpacing.md,
              mainAxisSpacing: AuxSpacing.md,
              childAspectRatio: 0.8,
            ),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final p = playlists[index];
              return _PlaylistCard(playlist: p);
            },
          );
        }
        return ListView.builder(
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            final p = playlists[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: AuxSpacing.lg, vertical: AuxSpacing.xs),
              leading: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: AuxColors.inkRaised, borderRadius: BorderRadius.circular(AuxSpacing.radiusCard)),
                child: const Icon(Icons.queue_music, color: AuxColors.signalTeal),
              ),
              title: Text(p.name, style: AuxTypography.body.copyWith(color: AuxColors.paper)),
              subtitle: Text(p.description ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: AuxTypography.caption.copyWith(color: AuxColors.paperMuted)),
              onTap: () => context.push('/playlist/${p.id}'),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AuxColors.ember)),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AuxColors.danger))),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final dynamic playlist;
  const _PlaylistCard({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/playlist/${playlist.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: AuxColors.inkRaised, borderRadius: BorderRadius.circular(AuxSpacing.radiusCard)),
              child: const Icon(Icons.queue_music, size: 48, color: AuxColors.signalTeal),
            ),
          ),
          const SizedBox(height: AuxSpacing.sm),
          Text(playlist.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AuxTypography.body.copyWith(color: AuxColors.paper)),
        ],
      ),
    );
  }
}

class _DownloadedView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadedFilesAsync = ref.watch(downloadedFilesProvider);
    return downloadedFilesAsync.when(
      data: (downloads) {
        if (downloads.isEmpty) {
          return Center(
            child: Text('Downloaded tracks will appear here.', style: AuxTypography.body.copyWith(color: AuxColors.paperMuted)),
          );
        }
        
        final tracks = downloads.map((d) => Track(
          id: d.trackId,
          title: d.title ?? d.trackId,
          artistName: d.artistName ?? 'Unknown Artist',
          artworkUrl: d.artworkUrl,
          sourceId: d.trackId,
          artistId: '',
          albumName: '',
          albumId: '',
          thumbnailUrl: d.artworkUrl,
          licenseType: LicenseType.unknown,
          attributionString: '',
          sourceUrl: '',
          language: '',
          durationMs: 0,
          playCount: 0,
          offlineAllowed: true,
        )).toList();
        
        return ListView.builder(
          itemCount: tracks.length,
          itemBuilder: (context, index) {
            final track = tracks[index];
            final file = downloads[index];
            return TrackListTile(
              track: track,
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
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AuxColors.ember)),
      error: (_, __) => const SizedBox(),
    );
  }
}
