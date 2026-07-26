import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/providers/library_providers.dart';
import '../../core/widgets/track_list_tile.dart';
import '../../core/playback/playback_providers.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  const PlaylistDetailScreen({super.key, required this.playlistId});
  final String playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pid = int.tryParse(playlistId) ?? -1;
    final asyncPlaylist = ref.watch(playlistsProvider).whenData(
      (playlists) => playlists.firstWhere((p) => p.id == playlistId, orElse: () => throw Exception('Not found')),
    );
    final asyncTracks = ref.watch(playlistTracksProvider(pid));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: asyncPlaylist.when(
              data: (p) => Text(p.name),
              loading: () => const Text('Loading...'),
              error: (_, __) => const Text('Playlist'),
            ),
            backgroundColor: AuxColors.ink,
            surfaceTintColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                color: AuxColors.danger,
                onPressed: () {
                  ref.read(libraryRepositoryProvider).deletePlaylist(pid);
                  context.pop();
                },
              ),
              if (asyncTracks.hasValue && asyncTracks.value!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: AuxSpacing.sm),
                  child: IconButton(
                    icon: const Icon(Icons.play_circle_fill_rounded),
                    iconSize: 48,
                    color: AuxColors.ember,
                    onPressed: () {
                      final handler = ref.read(audioHandlerProvider);
                      final currentItem = handler.mediaItem.value;
                      final currentTrackId = currentItem?.extras?['trackId'] as String? ?? currentItem?.id;
                      final firstTrack = asyncTracks.value!.first;
                      
                      if (currentTrackId != firstTrack.id) {
                        handler.playTracks(asyncTracks.value!, startIndex: 0);
                      }
                      context.push(AppRoutes.nowPlaying);
                    },
                  ),
                ),
            ],
          ),
          asyncTracks.when(
            data: (tracks) {
              if (tracks.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'This playlist is empty.',
                      style: TextStyle(color: AuxColors.paperMuted),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final track = tracks[index];
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
                      // TODO: Add remove from playlist option via a bottom sheet
                    );
                  },
                  childCount: tracks.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AuxColors.ember)),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(
                child: Text('Error: $err', style: const TextStyle(color: AuxColors.danger)),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)), // Space for mini player
        ],
      ),
    );
  }
}
