import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/playback/playback_providers.dart';
import '../../services/pass_the_aux_service.dart';
import '../../services/audio_handler.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/track.dart';
import '../../core/providers/library_providers.dart';
import '../../services/download_manager.dart';
import '../../core/providers/aux_session_provider.dart';

class QueueScreen extends ConsumerStatefulWidget {
  const QueueScreen({super.key});

  @override
  ConsumerState<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends ConsumerState<QueueScreen> {
  bool _isDismissing = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Estimate item height at ~72px. Offset by -1 so the current song is slightly below the top.
    final currentIndex = ref.read(queueIndexProvider).valueOrNull ?? 0;
    final initialOffset = (currentIndex > 1 ? currentIndex - 1 : 0) * 72.0;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auxState = ref.watch(passTheAuxProvider);
    final isPartyMode = auxState.roomId != null;
    final queue = isPartyMode 
        ? auxState.sharedQueue.map((t) => t.toMediaItem()).toList()
        : (ref.watch(queueProvider).valueOrNull ?? []);
        
    final currentIndex = ref.watch(queueIndexProvider).valueOrNull ?? -1;

    return Dismissible(
      key: const Key('queue_screen_dismissible'),
      direction: DismissDirection.down,
      onDismissed: (_) {
        if (!_isDismissing && context.canPop()) {
          _isDismissing = true;
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AuxColors.ink,
        body: Container(
          decoration: BoxDecoration(
            gradient: AuxColors.nowPlayingRadialGradient(AuxColors.ember),
          ),
          child: SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(
                    'Up Next',
                    style: AuxTypography.titleMd.copyWith(color: AuxColors.paper),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AuxColors.paper),
                    onPressed: () => context.pop(),
                  ),
                ),
                Expanded(
                  child: queue.isEmpty
                    ? Center(
                        child: Text(
                          'No tracks in queue',
                          style: AuxTypography.body.copyWith(color: AuxColors.paperMuted),
                        ),
                      )
                    : NotificationListener<ScrollUpdateNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.pixels < -80 && !_isDismissing) {
                            _isDismissing = true;
                            context.pop();
                            return true;
                          }
                          return false;
                        },
              child: ReorderableListView.builder(
                scrollController: _scrollController,
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.all(AuxSpacing.md),
                itemCount: queue.length,
              onReorder: (oldIndex, newIndex) {
                ref.read(audioHandlerProvider).moveQueueItem(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final item = queue[index];
                final isPlaying = index == currentIndex;
                final track = item.toTrack();

                return ListTile(
                  key: ValueKey(item.id + index.toString()),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AuxSpacing.xs,
                    horizontal: AuxSpacing.sm,
                  ),
                  tileColor: isPlaying ? AuxColors.inkRaised : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
                  ),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isPartyMode)
                        ReorderableDragStartListener(
                          index: index,
                          child: const Padding(
                            padding: EdgeInsets.only(right: AuxSpacing.sm),
                            child: Icon(Icons.drag_handle_rounded, color: AuxColors.paperMuted),
                          ),
                        ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
                        child: item.artUri != null
                            ? Image.network(
                                item.artUri!.toString(),
                                width: 48,
                                height: 48,
                                cacheWidth: 150,
                                cacheHeight: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildPlaceholder(),
                              )
                            : _buildPlaceholder(),
                      ),
                    ],
                  ),
                  title: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AuxTypography.body.copyWith(
                      color: isPlaying ? AuxColors.ember : AuxColors.paper,
                      fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    item.artist ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AuxTypography.caption.copyWith(color: AuxColors.paperMuted),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPlaying)
                        const Icon(Icons.volume_up_rounded, color: AuxColors.ember, size: 20),
                      const SizedBox(width: AuxSpacing.xs),
                      _TrackTrailingActions(track: track),
                    ],
                  ),
                  onTap: () {
                    if (isPlaying) return;
                    ref.read(audioHandlerProvider).skipToQueueItem(index);
                  },
                );
              },
            ),
          ),
        ),
      ],
    ),
  ),
),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      color: AuxColors.inkRaised,
      child: const Icon(Icons.music_note_rounded, color: AuxColors.paperMuted),
    );
  }
}

class _TrackTrailingActions extends ConsumerWidget {
  final Track track;
  const _TrackTrailingActions({required this.track});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLikedAsync = ref.watch(isTrackLikedProvider(track.id));
    final isLiked = isLikedAsync.valueOrNull ?? false;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded),
          color: isLiked ? AuxColors.ember : AuxColors.paperMuted,
          onPressed: () {
            ref.read(libraryRepositoryProvider).toggleLikeTrack(track);
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded),
          color: AuxColors.paperMuted,
          onPressed: () => _showTrackOptions(context, ref, track),
        ),
      ],
    );
  }

  void _showTrackOptions(BuildContext context, WidgetRef ref, Track track) {
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
                  if (ref.watch(inAuxSessionProvider))
                    ListTile(
                      leading: const Icon(Icons.queue_music_rounded, color: AuxColors.ember),
                      title: Text('Add to Aux Queue', style: AuxTypography.body.copyWith(color: AuxColors.ember)),
                      onTap: () {
                        context.pop();
                        final auxState = ref.read(passTheAuxProvider);
                        if (auxState.isHost) {
                          ref.read(passTheAuxProvider.notifier).addTrackAsHost(track);
                        } else {
                          ref.read(passTheAuxProvider.notifier).addTrack(track);
                        }
                      },
                    ),
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
                      _showAddToPlaylistSheet(context, ref, track);
                    },
                  ),
                ],
            ),
          );
        });
      },
    );
  }

  void _showAddToPlaylistSheet(BuildContext context, WidgetRef outerRef, Track track) {
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
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.add_rounded, color: AuxColors.ember),
                        title: Text('Create new playlist', style: AuxTypography.body.copyWith(color: AuxColors.ember)),
                        onTap: () {
                          context.pop();
                          _showCreatePlaylistDialog(context, track);
                        },
                      ),
                      if (playlists.isNotEmpty) const Divider(color: AuxColors.ink),
                      if (playlists.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(AuxSpacing.xl),
                          child: Center(
                            heightFactor: 1,
                            child: Text('No playlists yet.', style: AuxTypography.body.copyWith(color: AuxColors.paperMuted)),
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

  void _showCreatePlaylistDialog(BuildContext context, Track track) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) => AlertDialog(
          backgroundColor: AuxColors.inkRaised,
          title: Text('New Playlist', style: AuxTypography.titleLg.copyWith(color: AuxColors.paper)),
          content: TextField(
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
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel', style: TextStyle(color: AuxColors.paperMuted)),
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
