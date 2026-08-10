import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/providers/library_providers.dart';
import '../../core/widgets/track_list_tile.dart';
import '../../core/playback/playback_providers.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/providers/aux_session_provider.dart';

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
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.lg, vertical: AuxSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: asyncPlaylist.when(
                            data: (p) => Text(
                              p.name,
                              style: AuxTypography.display.copyWith(color: AuxColors.paper, fontSize: 32),
                            ),
                            loading: () => Text('Loading...', style: AuxTypography.display.copyWith(color: AuxColors.paper, fontSize: 32)),
                            error: (_, __) => Text('Playlist', style: AuxTypography.display.copyWith(color: AuxColors.paper, fontSize: 32)),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded, color: AuxColors.paperMuted),
                          color: AuxColors.inkRaised,
                          onSelected: (val) {
                            if (val == 'rename') {
                              final currentName = asyncPlaylist.valueOrNull?.name ?? '';
                              final TextEditingController controller = TextEditingController(text: currentName);
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AuxColors.inkRaised,
                                  title: Text('Rename Playlist', style: AuxTypography.titleMd.copyWith(color: AuxColors.paper)),
                                  content: TextField(
                                    controller: controller,
                                    style: const TextStyle(color: AuxColors.paper),
                                    decoration: const InputDecoration(
                                      hintText: 'Playlist Name',
                                      hintStyle: TextStyle(color: AuxColors.paperMuted),
                                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AuxColors.paperMuted)),
                                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AuxColors.signalTeal)),
                                    ),
                                    autofocus: true,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel', style: TextStyle(color: AuxColors.paperMuted)),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (controller.text.trim().isNotEmpty && controller.text.trim() != currentName) {
                                          ref.read(libraryRepositoryProvider).renamePlaylist(pid, controller.text.trim());
                                        }
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text('Save', style: TextStyle(color: AuxColors.signalTeal)),
                                    ),
                                  ],
                                ),
                              );
                            } else if (val == 'delete') {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AuxColors.inkRaised,
                                  title: Text('Delete Playlist?', style: AuxTypography.titleMd.copyWith(color: AuxColors.paper)),
                                  content: Text('Are you sure you want to delete this playlist? This action cannot be undone.', style: AuxTypography.body.copyWith(color: AuxColors.paperMuted)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel', style: TextStyle(color: AuxColors.paperMuted)),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        ref.read(libraryRepositoryProvider).deletePlaylist(pid);
                                        context.pop();
                                      },
                                      child: const Text('Delete', style: TextStyle(color: AuxColors.danger)),
                                    ),
                                  ],
                                ),
                              );
                              } else if (val == 'add_to_aux') {
                                if (asyncTracks.hasValue) {
                                  for (final track in asyncTracks.value!) {
                                    addTrackToAuxSession(ref, track);
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Added ${asyncTracks.value!.length} tracks to party queue')),
                                  );
                                }
                              }
                            },
                            itemBuilder: (context) {
                              final inSession = ref.watch(inAuxSessionProvider);
                              return [
                                if (inSession)
                                  PopupMenuItem(
                                    value: 'add_to_aux',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.queue_music_rounded, color: AuxColors.ember, size: 20),
                                        const SizedBox(width: AuxSpacing.sm),
                                        Text('Add to Aux Queue', style: AuxTypography.body.copyWith(color: AuxColors.ember)),
                                      ],
                                    ),
                                  ),
                                PopupMenuItem(
                              value: 'rename',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit_rounded, color: AuxColors.paperMuted, size: 20),
                                  const SizedBox(width: AuxSpacing.sm),
                                  Text('Rename Playlist', style: AuxTypography.body.copyWith(color: AuxColors.paper)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(Icons.delete_outline_rounded, color: AuxColors.danger, size: 20),
                                  const SizedBox(width: AuxSpacing.sm),
                                  Text('Delete Playlist', style: AuxTypography.body.copyWith(color: AuxColors.danger)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: AuxSpacing.xl),
                  if (asyncTracks.hasValue && asyncTracks.value!.isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              final handler = ref.read(audioHandlerProvider);
                              final shuffledTracks = List.of(asyncTracks.value!)..shuffle();
                              handler.playTracks(shuffledTracks, startIndex: 0);
                              context.push(AppRoutes.nowPlaying);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AuxColors.inkRaised,
                              foregroundColor: AuxColors.paper,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: const Icon(Icons.shuffle_rounded),
                            label: const Text('Shuffle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: AuxSpacing.md),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              final handler = ref.read(audioHandlerProvider);
                              handler.playTracks(asyncTracks.value!, startIndex: 0);
                              context.push(AppRoutes.nowPlaying);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AuxColors.ember,
                              foregroundColor: AuxColors.ink,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Play', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: AuxSpacing.md),
                ],
              ),
            ),
          ),
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
              return SliverReorderableList(
                itemCount: tracks.length,
                onReorder: (oldIndex, newIndex) {
                  ref.read(libraryRepositoryProvider).reorderPlaylistTracks(pid, oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final track = tracks[index];
                  return ReorderableDelayedDragStartListener(
                    key: ValueKey(track.id),
                    index: index,
                    child: Container(
                      color: Colors.transparent, // Ensures the whole area is draggable
                      child: TrackListTile(
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
                        onRemove: () {
                          ref.read(libraryRepositoryProvider).removeTrackFromPlaylist(pid, track.id);
                        },
                      ),
                    ),
                  );
                },
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
