import 'package:flutter/material.dart';
import '../../data/models/track.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/library_providers.dart';
import '../../services/download_manager.dart';

class TrackListTile extends ConsumerWidget {
  const TrackListTile({
    super.key,
    required this.track,
    this.onTap,
    this.onRemove,
  });

  final Track track;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLikedAsync = ref.watch(isTrackLikedProvider(track.id));
    final isLiked = isLikedAsync.valueOrNull ?? false;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AuxSpacing.lg,
        vertical: AuxSpacing.xs,
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AuxColors.inkRaised,
          borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
        ),
        clipBehavior: Clip.antiAlias,
        child: track.artworkUrl != null
            ? Image.network(
                track.artworkUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.music_note_rounded,
                  color: AuxColors.paperMuted,
                ),
              )
            : const Icon(
                Icons.music_note_rounded,
                color: AuxColors.paperMuted,
              ),
      ),
      title: Text(
        track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AuxTypography.body.copyWith(color: AuxColors.paper),
      ),
      subtitle: Text(
        track.artistName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AuxTypography.caption.copyWith(color: AuxColors.signalTeal),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            ),
            color: isLiked ? AuxColors.ember : AuxColors.paperMuted,
            onPressed: () {
              ref.read(libraryRepositoryProvider).toggleLikeTrack(track);
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            color: AuxColors.paperMuted,
            onPressed: () => _showTrackOptions(context, ref),
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  void _showTrackOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AuxColors.inkRaised,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final downloadsAsync = ref.watch(downloadedFilesProvider);
            final isDownloaded = downloadsAsync.valueOrNull?.any((d) => d.trackId == track.id) ?? false;
            
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onRemove != null)
                    ListTile(
                      leading: const Icon(Icons.remove_circle_outline_rounded, color: AuxColors.danger),
                      title: Text('Remove from playlist', style: AuxTypography.body.copyWith(color: AuxColors.danger)),
                      onTap: () {
                        context.pop();
                        onRemove!();
                      },
                    )
                  else ...[
                    if (isDownloaded)
                      ListTile(
                        leading: const Icon(Icons.delete_outline, color: AuxColors.danger),
                        title: Text('Remove from downloads', style: AuxTypography.body.copyWith(color: AuxColors.danger)),
                        onTap: () {
                          context.pop();
                          ref.read(downloadManagerProvider).deleteDownload(track.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Removed ${track.title} from downloads')),
                          );
                        },
                      )
                    else
                      ListTile(
                        leading: const Icon(Icons.download_rounded, color: AuxColors.paper),
                        title: Text('Download for offline', style: AuxTypography.body.copyWith(color: AuxColors.paper)),
                        onTap: () async {
                          context.pop();
                          
                          final manager = ref.read(downloadManagerProvider);
                          if (manager.isDownloading(track.id)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('This song is already downloading')),
                            );
                            return;
                          }
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Downloading ${track.title}...')),
                            );
                          }
                          
                          manager.downloadTrack(track).catchError((e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to download: $e')),
                              );
                            }
                          });
                        },
                      ),
                    ListTile(
                      leading: const Icon(Icons.playlist_add_rounded, color: AuxColors.paper),
                      title: Text('Add to playlist', style: AuxTypography.body.copyWith(color: AuxColors.paper)),
                      onTap: () {
                        context.pop();
                        _showAddToPlaylistSheet(context, ref);
                      },
                    ),
                  ],
                ],
            ),
          );
        });
      },
    );
  }

  void _showAddToPlaylistSheet(BuildContext context, WidgetRef outerRef) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AuxColors.inkRaised,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final playlistsAsync = ref.watch(playlistsProvider);
            return SafeArea(
              child: playlistsAsync.when(
                data: (playlists) {
                  if (playlists.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(AuxSpacing.xl),
                      child: Center(
                        heightFactor: 1,
                        child: Text('No playlists yet.', style: AuxTypography.body.copyWith(color: AuxColors.paperMuted)),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: playlists.length,
                    itemBuilder: (context, i) {
                      final p = playlists[i];
                      return ListTile(
                        leading: const Icon(Icons.queue_music, color: AuxColors.paperMuted),
                        title: Text(p.name, style: AuxTypography.body.copyWith(color: AuxColors.paper)),
                        onTap: () {
                          ref.read(libraryRepositoryProvider).addTrackToPlaylist(int.parse(p.id), track);
                          context.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added to ${p.name}')),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                error: (_, __) => const SizedBox(),
              ),
            );
          },
        );
      },
    );
  }
}
