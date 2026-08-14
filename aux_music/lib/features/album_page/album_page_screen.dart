import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/di/providers.dart';
import '../../core/widgets/track_list_tile.dart';
import '../../core/playback/playback_providers.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';

class AlbumPageScreen extends ConsumerWidget {
  const AlbumPageScreen({super.key, required this.albumId});
  final String albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(albumTracksProvider(albumId));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Album'),
            backgroundColor: context.colors.ink,
            surfaceTintColor: Colors.transparent,
            actions: [
              // Play All button
              if (tracksAsync.hasValue && tracksAsync.value!.isNotEmpty)
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
                      final firstTrack = tracksAsync.value!.first;
                      
                      if (currentTrackId != firstTrack.id) {
                        handler.playTracks(tracksAsync.value!, startIndex: 0);
                      }
                      context.push(AppRoutes.nowPlaying);
                    },
                  ),
                ),
            ],
          ),
          tracksAsync.when(
            data: (tracks) {
              if (tracks.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No tracks found for this album.',
                      style: TextStyle(color: context.colors.paperMuted),
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
