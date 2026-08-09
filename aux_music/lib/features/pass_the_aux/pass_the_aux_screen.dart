import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/pass_the_aux_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/router/app_router.dart';

class PassTheAuxScreen extends ConsumerStatefulWidget {
  const PassTheAuxScreen({super.key});

  @override
  ConsumerState<PassTheAuxScreen> createState() => _PassTheAuxScreenState();
}

class _PassTheAuxScreenState extends ConsumerState<PassTheAuxScreen>
    with SingleTickerProviderStateMixin {
  final _joinCodeController = TextEditingController();
  bool _showJoinInput = false;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-connect when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(passTheAuxProvider);
      if (!state.isConnected && !state.isConnecting) {
        ref.read(passTheAuxProvider.notifier).connect();
      }
    });

    // Listen for track-added confirmations (snackbars)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(passTheAuxProvider.notifier).onTrackAddedConfirmation.listen((msg) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg, style: AuxTypography.body.copyWith(color: AuxColors.paper)),
              backgroundColor: AuxColors.inkRaised,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _joinCodeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passTheAuxProvider);
    final notifier = ref.read(passTheAuxProvider.notifier);

    return Scaffold(
      backgroundColor: AuxColors.ink,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
                  .animate(animation),
              child: child,
            ),
          ),
          child: state.roomId != null
              ? _InRoomView(
                  key: const ValueKey('in-room'),
                  state: state,
                  notifier: notifier,
                  pulseAnimation: _pulseAnimation,
                )
              : _LandingView(
                  key: const ValueKey('landing'),
                  state: state,
                  notifier: notifier,
                  joinCodeController: _joinCodeController,
                  showJoinInput: _showJoinInput,
                  onToggleJoin: () => setState(() => _showJoinInput = !_showJoinInput),
                ),
        ),
      ),
    );
  }
}

// ── Landing View ─────────────────────────────────────────────────────────────

class _LandingView extends ConsumerWidget {
  const _LandingView({
    super.key,
    required this.state,
    required this.notifier,
    required this.joinCodeController,
    required this.showJoinInput,
    required this.onToggleJoin,
  });

  final PassTheAuxState state;
  final PassTheAuxNotifier notifier;
  final TextEditingController joinCodeController;
  final bool showJoinInput;
  final VoidCallback onToggleJoin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AuxSpacing.lg, AuxSpacing.xl, AuxSpacing.lg, AuxSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Text(
            'Pass the Aux',
            style: AuxTypography.display.copyWith(color: AuxColors.paper, fontSize: 26),
          ),
          const SizedBox(height: 4),
          Text(
            'Share music. Together, in real time.',
            style: AuxTypography.body.copyWith(color: AuxColors.paperMuted),
          ),

          const SizedBox(height: 40),

          // ── Connection Status ──
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: state.isConnecting
                ? _ConnectionBanner(key: const ValueKey('connecting'))
                : state.isConnected
                    ? const SizedBox.shrink(key: ValueKey('ok'))
                    : _ErrorBanner(
                        key: const ValueKey('error'),
                        message: state.error ?? 'Tap below to connect.',
                        onRetry: () => notifier.connect(),
                      ),
          ),

          // ── Action Cards (always visible) ──
          const SizedBox(height: 8),

          // ── Host Card ──
          _ActionCard(
            icon: Icons.wifi_tethering_rounded,
            iconColor: AuxColors.ember,
            title: 'Host a Party',
            subtitle: 'Create a room instantly. Share the code with friends so they can add songs.',
            onTap: () => notifier.createRoom(),
            accentColor: AuxColors.ember,
          ),

          const SizedBox(height: AuxSpacing.md),

          // ── Join Card ──
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: Column(
              children: [
                _ActionCard(
                  icon: Icons.group_add_rounded,
                  iconColor: AuxColors.signalTeal,
                  title: 'Join a Party',
                  subtitle: state.isConnected
                      ? 'Enter a room code to join a friend\'s session.'
                      : 'Connecting to server…',
                  onTap: state.isConnected ? onToggleJoin : null,
                  accentColor: AuxColors.signalTeal,
                  trailing: state.isConnected
                      ? Icon(
                          showJoinInput ? Icons.expand_less : Icons.expand_more,
                          color: AuxColors.paperMuted,
                        )
                      : const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AuxColors.signalTeal,
                          ),
                        ),
                ),
                if (showJoinInput) ...[
                  const SizedBox(height: AuxSpacing.sm),
                  _JoinInputCard(
                    controller: joinCodeController,
                    onJoin: (code) => notifier.joinRoom(code),
                  ),
                ],
              ],
            ),
          ),


          if (!state.isConnected && !state.isConnecting) ...[
            const SizedBox(height: AuxSpacing.xl),
            _PrimaryButton(
              label: 'Connect to Server',
              icon: Icons.cloud_rounded,
              onTap: () => notifier.connect(),
            ),
          ],

          if (state.error != null && !state.isConnecting) ...[
            const SizedBox(height: AuxSpacing.md),
            Container(
              padding: const EdgeInsets.all(AuxSpacing.md),
              decoration: BoxDecoration(
                color: AuxColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
                border: Border.all(color: AuxColors.danger.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AuxColors.danger, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: AuxTypography.caption.copyWith(color: AuxColors.danger),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AuxSpacing.xl),

          // ── Feature explainer ──
          const _FeatureDivider(label: 'HOW IT WORKS'),
          const SizedBox(height: AuxSpacing.lg),

          _FeatureCard(
            icon: Icons.queue_music_rounded,
            color: AuxColors.ember,
            title: 'Party Mode',
            subtitle: 'Democratic Jukebox',
            steps: const [
              _Step(
                icon: Icons.wifi_tethering_rounded,
                text: 'One person taps "Host a Party" — they control playback on their phone.',
              ),
              _Step(
                icon: Icons.share_rounded,
                text: 'Share the 6-character room code with friends. They tap "Join a Party" and enter it.',
              ),
              _Step(
                icon: Icons.touch_app_rounded,
                text: 'Friends search any song in the app and tap it — it goes straight into the host\'s queue.',
              ),
              _Step(
                icon: Icons.queue_rounded,
                text: 'The host sees all added songs in the Shared Queue and can swipe to remove any.',
              ),
            ],
          ),

          const SizedBox(height: AuxSpacing.md),

          _FeatureCard(
            icon: Icons.headphones_rounded,
            color: AuxColors.signalTeal,
            title: 'Synced Audio',
            subtitle: 'Listen Together',
            steps: const [
              _Step(
                icon: Icons.group_rounded,
                text: 'Join a room as a guest. You\'ll see what the host is playing.',
              ),
              _Step(
                icon: Icons.sync_rounded,
                text: 'Toggle "Listen Along" — your audio will instantly sync to the host\'s track, position, and play state.',
              ),
              _Step(
                icon: Icons.speed_rounded,
                text: 'If you drift more than 2 seconds, the app silently re-syncs every 5 seconds.',
              ),
              _Step(
                icon: Icons.headset_mic_rounded,
                text: 'Everyone hears the same song at the same moment — perfect for rooms, drives, or hangouts.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── In-Room View ─────────────────────────────────────────────────────────────

class _InRoomView extends StatelessWidget {
  const _InRoomView({
    super.key,
    required this.state,
    required this.notifier,
    required this.pulseAnimation,
  });

  final PassTheAuxState state;
  final PassTheAuxNotifier notifier;
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    return state.isHost
        ? _HostRoomView(state: state, notifier: notifier)
        : _GuestRoomView(state: state, notifier: notifier, pulseAnimation: pulseAnimation);
  }
}

// ── Host Room View ────────────────────────────────────────────────────────────

class _HostRoomView extends StatelessWidget {
  const _HostRoomView({required this.state, required this.notifier});
  final PassTheAuxState state;
  final PassTheAuxNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header Bar ──
        Padding(
          padding: const EdgeInsets.fromLTRB(AuxSpacing.lg, AuxSpacing.xl, AuxSpacing.lg, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Pass the Aux',
                  style: AuxTypography.display.copyWith(color: AuxColors.paper, fontSize: 26),
                ),
              ),
              _GuestCountBadge(count: state.guestCount),
              const SizedBox(width: AuxSpacing.sm),
              TextButton.icon(
                onPressed: () => notifier.leaveRoom(),
                icon: const Icon(Icons.close_rounded, size: 16, color: AuxColors.danger),
                label: Text('End', style: AuxTypography.buttonSm.copyWith(color: AuxColors.danger)),
                style: TextButton.styleFrom(
                  backgroundColor: AuxColors.danger.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AuxSpacing.lg),

        // ── Room Code Card ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.lg),
          child: _RoomCodeCard(roomId: state.roomId!),
        ),

        const SizedBox(height: AuxSpacing.md),

        // ── Now Playing (if any) ──
        if (state.nowPlaying != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.lg),
            child: _NowPlayingCard(track: state.nowPlaying!, isPlaying: state.isPlaying),
          ),

        const SizedBox(height: AuxSpacing.md),

        // ── Queue Header ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.lg),
          child: Row(
            children: [
              Text('Shared Queue', style: AuxTypography.titleMd.copyWith(color: AuxColors.paper)),
              if (state.sharedQueue.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AuxColors.ember.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${state.sharedQueue.length}',
                    style: AuxTypography.captionMedium.copyWith(color: AuxColors.ember),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                'Swipe to remove',
                style: AuxTypography.caption.copyWith(color: AuxColors.paperMuted),
              ),
            ],
          ),
        ),

        const SizedBox(height: AuxSpacing.sm),

        // ── Queue List ──
        Expanded(
          child: state.sharedQueue.isEmpty
              ? _EmptyQueuePlaceholder(isHost: true)
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: AuxSpacing.xxxl),
                  itemCount: state.sharedQueue.length,
                  itemBuilder: (context, index) {
                    final track = state.sharedQueue[index];
                    return Dismissible(
                      key: ValueKey('${track.id}_$index'),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => notifier.kickTrack(index),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: AuxSpacing.lg),
                        color: AuxColors.danger.withValues(alpha: 0.2),
                        child: const Icon(Icons.delete_outline, color: AuxColors.danger),
                      ),
                      child: _QueueTrackTile(track: track, index: index),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ── Guest Room View ───────────────────────────────────────────────────────────

class _GuestRoomView extends StatelessWidget {
  const _GuestRoomView({
    required this.state,
    required this.notifier,
    required this.pulseAnimation,
  });

  final PassTheAuxState state;
  final PassTheAuxNotifier notifier;
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header Bar ──
        Padding(
          padding: const EdgeInsets.fromLTRB(AuxSpacing.lg, AuxSpacing.xl, AuxSpacing.lg, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pass the Aux',
                      style:
                          AuxTypography.display.copyWith(color: AuxColors.paper, fontSize: 26),
                    ),
                    Text(
                      'Room ${state.roomId}',
                      style: AuxTypography.caption.copyWith(color: AuxColors.paperMuted),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => notifier.leaveRoom(),
                icon: const Icon(Icons.exit_to_app_rounded, size: 16, color: AuxColors.danger),
                label:
                    Text('Leave', style: AuxTypography.buttonSm.copyWith(color: AuxColors.danger)),
                style: TextButton.styleFrom(
                  backgroundColor: AuxColors.danger.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AuxSpacing.lg),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AuxSpacing.lg, 0, AuxSpacing.lg, AuxSpacing.xxxl),
            children: [
              // ── Now Playing ──
              if (state.nowPlaying != null)
                _NowPlayingCard(track: state.nowPlaying!, isPlaying: state.isPlaying),

              const SizedBox(height: AuxSpacing.md),

              // ── Synced Audio Toggle ──
              _SyncModeCard(
                state: state,
                notifier: notifier,
                pulseAnimation: pulseAnimation,
              ),

              const SizedBox(height: AuxSpacing.md),

              // ── Add Song CTA ──
              _AddSongCard(
                onTap: () => context.go(AppRoutes.search),
              ),

              const SizedBox(height: AuxSpacing.lg),

              // ── Queue Header ──
              Row(
                children: [
                  Text('Queue', style: AuxTypography.titleMd.copyWith(color: AuxColors.paper)),
                  if (state.sharedQueue.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AuxColors.signalTeal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${state.sharedQueue.length}',
                        style:
                            AuxTypography.captionMedium.copyWith(color: AuxColors.signalTeal),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: AuxSpacing.sm),

              // ── Queue List (read-only for guests) ──
              if (state.sharedQueue.isEmpty)
                const _EmptyQueuePlaceholder(isHost: false)
              else
                ...state.sharedQueue.asMap().entries.map(
                      (e) => _QueueTrackTile(track: e.value, index: e.key),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Sub-Widgets ───────────────────────────────────────────────────────────────

class _ConnectionBanner extends StatelessWidget {
  const _ConnectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.md, vertical: AuxSpacing.sm),
      decoration: BoxDecoration(
        color: AuxColors.inkRaised,
        borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AuxColors.ember,
            ),
          ),
          const SizedBox(width: AuxSpacing.sm),
          Text(
            'Connecting to server…',
            style: AuxTypography.caption.copyWith(color: AuxColors.paperMuted),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AuxSpacing.md),
      decoration: BoxDecoration(
        color: AuxColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
        border: Border.all(color: AuxColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AuxColors.danger, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AuxTypography.caption.copyWith(color: AuxColors.danger),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text('Retry', style: AuxTypography.buttonSm.copyWith(color: AuxColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.accentColor,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;  // nullable — null disables the card
  final Color accentColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: disabled ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(AuxSpacing.lg),
          decoration: BoxDecoration(
            color: AuxColors.inkRaised,
            borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
            border: Border.all(
              color: disabled
                  ? AuxColors.hairline
                  : accentColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: AuxSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AuxTypography.titleMd.copyWith(color: AuxColors.paper)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AuxTypography.caption.copyWith(color: AuxColors.paperMuted),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _JoinInputCard extends StatefulWidget {
  const _JoinInputCard({required this.controller, required this.onJoin});
  final TextEditingController controller;
  final Function(String) onJoin;

  @override
  State<_JoinInputCard> createState() => _JoinInputCardState();
}

class _JoinInputCardState extends State<_JoinInputCard>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AuxSpacing.md),
      decoration: BoxDecoration(
        color: AuxColors.inkRaised,
        borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
        border: Border.all(color: AuxColors.signalTeal.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // ── Tab bar ──
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: AuxColors.ink,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabCtrl,
              indicator: BoxDecoration(
                color: AuxColors.signalTeal,
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AuxColors.ink,
              unselectedLabelColor: AuxColors.paperMuted,
              labelStyle: AuxTypography.captionMedium,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Enter Code'),
                Tab(text: 'Scan QR'),
              ],
            ),
          ),

          const SizedBox(height: AuxSpacing.sm),

          // ── Tab content ──
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _tabCtrl.index == 0
                ? _EnterCodeTab(
                    key: const ValueKey('enter'),
                    controller: widget.controller,
                    onJoin: widget.onJoin,
                  )
                : _ScanQrTab(
                    key: const ValueKey('scan'),
                    onJoin: widget.onJoin,
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Enter Code tab ──
class _EnterCodeTab extends StatelessWidget {
  const _EnterCodeTab({super.key, required this.controller, required this.onJoin});
  final TextEditingController controller;
  final Function(String) onJoin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          style: AuxTypography.titleMd.copyWith(
            color: AuxColors.paper,
            letterSpacing: 4,
          ),
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'A3F91C',
            hintStyle: AuxTypography.titleMd.copyWith(
              color: AuxColors.paperMuted.withValues(alpha: 0.4),
              letterSpacing: 4,
            ),
            filled: true,
            fillColor: AuxColors.ink,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: AuxSpacing.md, vertical: 14),
          ),
        ),
        const SizedBox(height: AuxSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onJoin(controller.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AuxColors.signalTeal,
              foregroundColor: AuxColors.ink,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child:
                Text('Join Room', style: AuxTypography.button.copyWith(color: AuxColors.ink)),
          ),
        ),
      ],
    );
  }
}

// ── Scan QR tab ──
class _ScanQrTab extends StatelessWidget {
  const _ScanQrTab({super.key, required this.onJoin});
  final Function(String) onJoin;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _openScanner(context),
        icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
        label: Text('Open Camera Scanner',
            style: AuxTypography.button.copyWith(color: AuxColors.ink)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AuxColors.signalTeal,
          foregroundColor: AuxColors.ink,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  void _openScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuxColors.inkRaised,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _QrScannerSheet(
        onScanned: (code) {
          Navigator.pop(context);
          onJoin(code);
        },
      ),
    );
  }
}


class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: AuxTypography.button),
        style: ElevatedButton.styleFrom(
          backgroundColor: AuxColors.ember,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
      ),
    );
  }
}


class _RoomCodeCard extends StatefulWidget {
  const _RoomCodeCard({required this.roomId});
  final String roomId;

  @override
  State<_RoomCodeCard> createState() => _RoomCodeCardState();
}

class _RoomCodeCardState extends State<_RoomCodeCard> {
  bool _showQr = false;

  @override
  Widget build(BuildContext context) {
    // QR data: AUX-XXXXXX — scanned by guests to auto-fill the code
    final qrData = 'AUX-${widget.roomId}';

    return Container(
      padding: const EdgeInsets.all(AuxSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AuxColors.ember.withValues(alpha: 0.18),
            AuxColors.ember.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
        border: Border.all(color: AuxColors.ember.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Code + Buttons row ──
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ROOM CODE',
                      style: AuxTypography.buttonSm.copyWith(
                        letterSpacing: 2.5,
                        color: AuxColors.paperMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.roomId,
                      style: AuxTypography.display.copyWith(
                        letterSpacing: 8,
                        fontSize: 30,
                        color: AuxColors.ember,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Share this code with friends',
                      style: AuxTypography.caption.copyWith(color: AuxColors.paperMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AuxSpacing.sm),
              // Copy button
              _IconBtn(
                icon: Icons.copy_rounded,
                color: AuxColors.ember,
                tooltip: 'Copy code',
                onTap: () {
                  Clipboard.setData(ClipboardData(text: widget.roomId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Room code copied!',
                          style: AuxTypography.body.copyWith(color: AuxColors.paper)),
                      backgroundColor: AuxColors.inkRaised,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(width: AuxSpacing.xs),
              // QR toggle button
              _IconBtn(
                icon: _showQr ? Icons.qr_code_2_rounded : Icons.qr_code_rounded,
                color: AuxColors.ember,
                tooltip: _showQr ? 'Hide QR code' : 'Show QR code',
                onTap: () => setState(() => _showQr = !_showQr),
              ),
            ],
          ),

          // ── QR Code (animated expand) ──
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: _showQr
                ? Padding(
                    padding: const EdgeInsets.only(top: AuxSpacing.lg),
                    child: Center(
                      child: Column(
                        children: [
                          // QrImageView generates QR locally — no internet needed
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: QrImageView(
                              data: qrData,
                              version: QrVersions.auto,
                              size: 180,
                              gapless: false,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: Colors.black,
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: AuxSpacing.sm),
                          Text(
                            'Friends scan this to join',
                            style: AuxTypography.caption
                                .copyWith(color: AuxColors.paperMuted),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// Small icon button helper
class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    this.tooltip = '',
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}

class _GuestCountBadge extends StatelessWidget {
  const _GuestCountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AuxColors.signalTeal.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AuxColors.signalTeal.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_rounded, size: 14, color: AuxColors.signalTeal),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: AuxTypography.captionMedium.copyWith(color: AuxColors.signalTeal),
          ),
        ],
      ),
    );
  }
}

class _NowPlayingCard extends StatelessWidget {
  const _NowPlayingCard({required this.track, required this.isPlaying});
  final dynamic track;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AuxSpacing.md),
      decoration: BoxDecoration(
        color: AuxColors.inkRaised,
        borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 52,
              height: 52,
              color: AuxColors.hairline,
              child: track.thumbnailUrl != null || track.artworkUrl != null
                  ? Image.network(
                      track.thumbnailUrl ?? track.artworkUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.music_note_rounded, color: AuxColors.paperMuted),
                    )
                  : const Icon(Icons.music_note_rounded, color: AuxColors.paperMuted),
            ),
          ),
          const SizedBox(width: AuxSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Now Playing',
                  style: AuxTypography.caption.copyWith(color: AuxColors.paperMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  track.title,
                  style: AuxTypography.bodySemiBold.copyWith(color: AuxColors.paper),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  track.artistName,
                  style: AuxTypography.caption.copyWith(color: AuxColors.paperMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            isPlaying ? Icons.equalizer_rounded : Icons.pause_circle_outline_rounded,
            color: isPlaying ? AuxColors.ember : AuxColors.paperMuted,
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _SyncModeCard extends StatelessWidget {
  const _SyncModeCard({
    required this.state,
    required this.notifier,
    required this.pulseAnimation,
  });

  final PassTheAuxState state;
  final PassTheAuxNotifier notifier;
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    final isOn = state.isSyncModeEnabled;
    return Container(
      decoration: BoxDecoration(
        color: AuxColors.inkRaised,
        borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
        border: Border.all(
          color: isOn ? AuxColors.signalTeal.withValues(alpha: 0.5) : AuxColors.hairline,
          width: isOn ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AuxSpacing.md, vertical: AuxSpacing.xs),
        leading: AnimatedBuilder(
          animation: pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isOn ? pulseAnimation.value : 1.0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isOn
                      ? AuxColors.signalTeal.withValues(alpha: 0.2)
                      : AuxColors.hairline,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.sync_rounded,
                  color: isOn ? AuxColors.signalTeal : AuxColors.paperMuted,
                  size: 20,
                ),
              ),
            );
          },
        ),
        title: Row(
          children: [
            Text('Listen Along', style: AuxTypography.bodySemiBold.copyWith(color: AuxColors.paper)),
            if (isOn) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AuxColors.signalTeal.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'SYNCED',
                  style: AuxTypography.buttonSm.copyWith(
                    color: AuxColors.signalTeal,
                    letterSpacing: 1.5,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          isOn
              ? 'Playing what the host is playing in real time.'
              : 'Enable to hear exactly what the host is playing.',
          style: AuxTypography.caption.copyWith(color: AuxColors.paperMuted),
        ),
        trailing: Switch(
          value: isOn,
          onChanged: (v) => notifier.toggleSyncMode(v),
          activeColor: AuxColors.signalTeal,
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
    );
  }
}

class _AddSongCard extends StatelessWidget {
  const _AddSongCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AuxSpacing.md),
        decoration: BoxDecoration(
          color: AuxColors.ember.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
          border: Border.all(color: AuxColors.ember.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AuxColors.ember.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: AuxColors.ember, size: 22),
            ),
            const SizedBox(width: AuxSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add a Song',
                  style: AuxTypography.bodySemiBold.copyWith(color: AuxColors.paper),
                ),
                Text(
                  'Go to Search and tap any track.',
                  style: AuxTypography.caption.copyWith(color: AuxColors.paperMuted),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, color: AuxColors.paperMuted, size: 14),
          ],
        ),
      ),
    );
  }
}

class _QueueTrackTile extends StatelessWidget {
  const _QueueTrackTile({required this.track, required this.index});
  final dynamic track;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '${index + 1}',
              style: AuxTypography.tabularDuration.copyWith(color: AuxColors.paperMuted),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 44,
              height: 44,
              color: AuxColors.hairline,
              child: track.thumbnailUrl != null || track.artworkUrl != null
                  ? Image.network(
                      track.thumbnailUrl ?? track.artworkUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.music_note, color: AuxColors.paperMuted, size: 18),
                    )
                  : const Icon(Icons.music_note, color: AuxColors.paperMuted, size: 18),
            ),
          ),
        ],
      ),
      title: Text(
        track.title,
        style: AuxTypography.bodyLg.copyWith(color: AuxColors.paper),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track.artistName,
        style: AuxTypography.caption.copyWith(color: AuxColors.paperMuted),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _EmptyQueuePlaceholder extends StatelessWidget {
  const _EmptyQueuePlaceholder({required this.isHost});
  final bool isHost;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isHost ? Icons.queue_music_rounded : Icons.music_note_rounded,
              color: AuxColors.hairline,
              size: 56,
            ),
            const SizedBox(height: AuxSpacing.md),
            Text(
              isHost ? 'Queue is empty' : 'Nothing queued yet',
              style: AuxTypography.titleMd.copyWith(color: AuxColors.paperMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              isHost
                  ? 'Guests can add songs from anywhere in the app.'
                  : 'Tap "Add a Song" above to suggest one.',
              style: AuxTypography.caption.copyWith(color: AuxColors.paperMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Feature Explainer Widgets ─────────────────────────────────────────────────

class _Step {
  const _Step({required this.icon, required this.text});
  final IconData icon;
  final String text;
}

class _FeatureDivider extends StatelessWidget {
  const _FeatureDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AuxColors.hairline)),
        const SizedBox(width: AuxSpacing.sm),
        Text(
          label,
          style: AuxTypography.buttonSm.copyWith(
            color: AuxColors.paperMuted,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: AuxSpacing.sm),
        Expanded(child: Container(height: 1, color: AuxColors.hairline)),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.steps,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final List<_Step> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AuxSpacing.lg),
      decoration: BoxDecoration(
        color: AuxColors.inkRaised,
        borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: AuxSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AuxTypography.bodySemiBold.copyWith(color: AuxColors.paper),
                  ),
                  Text(
                    subtitle,
                    style: AuxTypography.caption.copyWith(color: color),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AuxSpacing.md),
          // Steps
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            return Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : AuxSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step number bubble
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: AuxTypography.buttonSm.copyWith(
                          color: color,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AuxSpacing.sm),
                  Expanded(
                    child: Text(
                      step.text,
                      style: AuxTypography.caption.copyWith(
                        color: AuxColors.paperMuted,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── QR Code Scanner Sheet ──────────────────────────────────────────────────────

class _QrScannerSheet extends StatefulWidget {
  const _QrScannerSheet({required this.onScanned});
  final Function(String code) onScanned;

  @override
  State<_QrScannerSheet> createState() => _QrScannerSheetState();
}

class _QrScannerSheetState extends State<_QrScannerSheet> {
  late final MobileScannerController _ctrl;
  bool _scanned = false;

  @override
  void initState() {
    super.initState();
    _ctrl = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw != null) {
        // Accept "AUX-XXXXXX" (our QR format) or plain "XXXXXX"
        final code = raw.startsWith('AUX-') ? raw.substring(4) : raw;
        if (code.trim().length == 6) {
          _scanned = true;
          widget.onScanned(code.trim().toUpperCase());
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.62,
      child: Column(
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AuxColors.hairline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(AuxSpacing.lg, 0, AuxSpacing.sm, 0),
            child: Row(
              children: [
                Text('Scan QR Code',
                    style: AuxTypography.titleMd.copyWith(color: AuxColors.paper)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AuxColors.paperMuted),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: AuxSpacing.md),
            child: Text(
              'Point at the host\'s QR code to join instantly',
              style: AuxTypography.caption.copyWith(color: AuxColors.paperMuted),
            ),
          ),

          // Camera view with teal aim overlay
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              child: Stack(
                children: [
                  MobileScanner(controller: _ctrl, onDetect: _onDetect),
                  Center(
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        border: Border.all(color: AuxColors.signalTeal, width: 2.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: AuxSpacing.xl,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AuxSpacing.md, vertical: 8),
                        decoration: BoxDecoration(
                          color: AuxColors.inkRaised.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Searching for QR code…',
                          style: AuxTypography.caption
                              .copyWith(color: AuxColors.signalTeal),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
