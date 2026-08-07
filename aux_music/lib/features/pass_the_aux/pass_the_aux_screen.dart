import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/pass_the_aux_service.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../search/widgets/track_list_tile.dart';

class PassTheAuxScreen extends ConsumerStatefulWidget {
  const PassTheAuxScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PassTheAuxScreen> createState() => _PassTheAuxScreenState();
}

class _PassTheAuxScreenState extends ConsumerState<PassTheAuxScreen> {
  final TextEditingController _roomController = TextEditingController();

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passTheAuxProvider);
    final notifier = ref.read(passTheAuxProvider.notifier);

    return Scaffold(
      backgroundColor: AuxColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AuxColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Pass the Aux', style: AuxTypography.titleLarge),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!state.isConnected) ...[
                const Spacer(),
                const Icon(Icons.speaker_group, size: 80, color: AuxColors.ember),
                const SizedBox(height: 24),
                Text(
                  'Connect to Cloud Relay',
                  style: AuxTypography.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'To use Pass the Aux, you need to connect to the cloud server.',
                  style: AuxTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => notifier.connect(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuxColors.ember,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text('Connect', style: AuxTypography.titleMedium),
                ),
                if (state.error != null) ...[
                  const SizedBox(height: 16),
                  Text(state.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                ],
                const Spacer(),
              ] else if (state.roomId == null) ...[
                const Spacer(),
                const Icon(Icons.group_add, size: 80, color: AuxColors.ember),
                const SizedBox(height: 24),
                Text(
                  'Start a Party',
                  style: AuxTypography.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => notifier.createRoom(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuxColors.ember,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text('Create Room (Host)', style: AuxTypography.titleMedium),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    const Expanded(child: Divider(color: AuxColors.textSecondary)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('OR', style: AuxTypography.labelMedium),
                    ),
                    const Expanded(child: Divider(color: AuxColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _roomController,
                  style: AuxTypography.bodyLarge,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter Room Code',
                    hintStyle: AuxTypography.bodyLarge.copyWith(color: AuxColors.textSecondary),
                    filled: true,
                    fillColor: AuxColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_roomController.text.isNotEmpty) {
                      notifier.joinRoom(_roomController.text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuxColors.surfaceHighlight,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text('Join Room (Guest)', style: AuxTypography.titleMedium),
                ),
                if (state.error != null) ...[
                  const SizedBox(height: 16),
                  Text(state.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                ],
                const Spacer(),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AuxColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AuxColors.ember.withOpacity(0.3), width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'ROOM CODE',
                        style: AuxTypography.labelMedium.copyWith(letterSpacing: 2, color: AuxColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.roomId!,
                        style: AuxTypography.display.copyWith(letterSpacing: 8, color: AuxColors.ember),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  state.isHost 
                    ? 'You are the Host. Guests can add songs to your queue.'
                    : 'You are a Guest. Songs you tap anywhere in the app will be added to the Host\'s queue.',
                  style: AuxTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (!state.isHost)
                  Container(
                    decoration: BoxDecoration(
                      color: AuxColors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      title: Text('Listen Along (Synced Audio)', style: AuxTypography.bodyLarge),
                      subtitle: Text(
                        'Automatically play what the host is playing in real-time.',
                        style: AuxTypography.caption.copyWith(color: AuxColors.textSecondary),
                      ),
                      activeColor: AuxColors.ember,
                      value: state.isSyncModeEnabled,
                      onChanged: (val) {
                        notifier.toggleSyncMode(val);
                      },
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Shared Queue', style: AuxTypography.titleLarge),
                    TextButton(
                      onPressed: () => notifier.leaveRoom(),
                      child: const Text('Leave', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: state.sharedQueue.isEmpty
                    ? Center(
                        child: Text(
                          'Queue is empty.\nGo search for some songs!',
                          style: AuxTypography.bodyLarge.copyWith(color: AuxColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: state.sharedQueue.length,
                        itemBuilder: (context, index) {
                          final track = state.sharedQueue[index];
                          // Simple UI representation of the track
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                track.thumbnailUrl ?? track.artworkUrl ?? '',
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (_,__,___) => Container(
                                  width: 48, height: 48, color: AuxColors.surfaceHighlight,
                                  child: const Icon(Icons.music_note, color: AuxColors.textSecondary),
                                ),
                              ),
                            ),
                            title: Text(track.title, style: AuxTypography.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(track.artistName, style: AuxTypography.bodyMedium.copyWith(color: AuxColors.textSecondary)),
                          );
                        },
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
