import 'package:flutter/material.dart';
import '../../data/models/track.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/library_providers.dart';
import '../../services/download_manager.dart';
import '../providers/aux_session_provider.dart';

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
          color: context.colors.inkRaised,
          borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
        ),
        clipBehavior: Clip.antiAlias,
        child: track.artworkUrl != null
            ? Image.network(
                track.artworkUrl!,
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
      title: Text(
        track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AuxTypography.body.copyWith(color: context.colors.paper),
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
            color: isLiked ? AuxColors.ember : context.colors.paperMuted,
            onPressed: () {
              ref.read(libraryRepositoryProvider).toggleLikeTrack(track);
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            color: context.colors.paperMuted,
            onPressed: () => _showTrackOptions(context, ref),
          ),
        ],
      ),
      onTap: () {
        final inSession = ref.read(inAuxSessionProvider);
        if (inSession) {
          addTrackToAuxSession(ref, track);
        } else if (onTap != null) {
          onTap!();
        }
      },
    );
  }

  void _showTrackOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.inkRaised,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final downloadsAsync = ref.watch(downloadedFilesProvider);
            final isDownloaded = downloadsAsync.valueOrNull?.any((d) => d.trackId == track.id) ?? false;
            
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (ref.watch(inAuxSessionProvider))
                    ListTile(
                      leading: const Icon(Icons.queue_music_rounded, color: AuxColors.ember),
                      title: Text('Add to Aux Queue', style: AuxTypography.body.copyWith(color: AuxColors.ember)),
                      onTap: () {
                        context.pop();
                        addTrackToAuxSession(ref, track);
                      },
                    ),
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
                        leading: Icon(Icons.download_rounded, color: context.colors.paper),
                        title: Text('Download for offline', style: AuxTypography.body.copyWith(color: context.colors.paper)),
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
                      leading: Icon(Icons.playlist_add_rounded, color: context.colors.paper),
                      title: Text('Add to playlist', style: AuxTypography.body.copyWith(color: context.colors.paper)),
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
      backgroundColor: context.colors.inkRaised,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final playlistsAsync = ref.watch(playlistsProvider);
            return SafeArea(
              child: playlistsAsync.when(
                data: (playlists) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.add_rounded, color: AuxColors.ember),
                        title: Text('Create new playlist', style: AuxTypography.body.copyWith(color: AuxColors.ember)),
                        onTap: () {
                          context.pop();
                          _showCreatePlaylistDialog(context);
                        },
                      ),
                      if (playlists.isNotEmpty) Divider(color: context.colors.ink),
                      if (playlists.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(AuxSpacing.xl),
                          child: Center(
                            heightFactor: 1,
                            child: Text('No playlists yet.', style: AuxTypography.body.copyWith(color: context.colors.paperMuted)),
                          ),
                        )
                      else
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: playlists.length,
                            itemBuilder: (context, i) {
                              final p = playlists[i];
                              return ListTile(
                                leading: Icon(Icons.queue_music, color: context.colors.paperMuted),
                                title: Text(p.name, style: AuxTypography.body.copyWith(color: context.colors.paper)),
                                onTap: () {
                                  ref.read(libraryRepositoryProvider).addTrackToPlaylist(int.parse(p.id), track);
                                  context.pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Added to ${p.name}')),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                    ],
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

  void _showCreatePlaylistDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) => AlertDialog(
          backgroundColor: context.colors.inkRaised,
          title: Text('New Playlist', style: AuxTypography.titleLg.copyWith(color: context.colors.paper)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: AuxTypography.body.copyWith(color: context.colors.paper),
            decoration: InputDecoration(
              hintText: 'Playlist name',
              hintStyle: TextStyle(color: context.colors.paperMuted),
              filled: true,
              fillColor: context.colors.ink,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text('Cancel', style: TextStyle(color: context.colors.paperMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AuxColors.ember,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  try {
                    final id = await ref.read(libraryRepositoryProvider).createPlaylist(name);
                    await ref.read(libraryRepositoryProvider).addTrackToPlaylist(id, track);
                    if (context.mounted) {
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added to $name')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
