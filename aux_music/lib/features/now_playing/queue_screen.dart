import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/playback/playback_providers.dart';
import 'package:go_router/go_router.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(queueProvider).valueOrNull ?? [];
    final currentIndex = ref.watch(queueIndexProvider).valueOrNull ?? -1;

    return Scaffold(
      backgroundColor: AuxColors.ink,
      appBar: AppBar(
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
      body: queue.isEmpty
          ? Center(
              child: Text(
                'No tracks in queue',
                style: AuxTypography.body.copyWith(color: AuxColors.paperMuted),
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(AuxSpacing.md),
              itemCount: queue.length,
              onReorder: (oldIndex, newIndex) {
                ref.read(audioHandlerProvider).moveQueueItem(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final item = queue[index];
                final isPlaying = index == currentIndex;

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
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
                    child: item.artUri != null
                        ? Image.network(
                            item.artUri!.toString(),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
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
                      const SizedBox(width: AuxSpacing.sm),
                      ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle_rounded, color: AuxColors.paperMuted),
                      ),
                    ],
                  ),
                  onTap: () {
                    ref.read(audioHandlerProvider).skipToQueueItem(index);
                  },
                );
              },
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
