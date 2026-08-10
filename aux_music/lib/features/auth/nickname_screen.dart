import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../services/auth_service.dart';

class NicknameScreen extends ConsumerStatefulWidget {
  const NicknameScreen({super.key});

  @override
  ConsumerState<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends ConsumerState<NicknameScreen> {
  late final TextEditingController _controller;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: generateGuestNickname());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a nickname.');
      return;
    }
    if (name.length < 2) {
      setState(() => _error = 'Nickname must be at least 2 characters.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authServiceProvider).signInAnonymously(displayName: name);
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Something went wrong. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuxColors.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.xl),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Icon ──
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AuxColors.inkRaised,
                  border: Border.all(
                      color: AuxColors.signalTeal.withValues(alpha: 0.4), width: 1.5),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AuxColors.signalTeal,
                  size: 34,
                ),
              ),

              const SizedBox(height: AuxSpacing.xl),

              Text(
                'Choose a Nickname',
                style: AuxTypography.titleLg.copyWith(color: AuxColors.paper),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This is how your friends will see you\nin Pass the Aux sessions.',
                style: AuxTypography.body.copyWith(color: AuxColors.paperMuted),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AuxSpacing.xxxl),

              // ── Nickname field ──
              TextField(
                controller: _controller,
                style: AuxTypography.titleMd.copyWith(color: AuxColors.paper),
                textAlign: TextAlign.center,
                maxLength: 24,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Your nickname',
                  hintStyle: AuxTypography.titleMd
                      .copyWith(color: AuxColors.paperMuted.withValues(alpha: 0.4)),
                  filled: true,
                  fillColor: AuxColors.inkRaised,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AuxColors.signalTeal, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AuxSpacing.lg,
                    vertical: AuxSpacing.lg,
                  ),
                  // Shuffle button to generate a new random nickname
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.shuffle_rounded, color: AuxColors.paperMuted),
                    tooltip: 'Suggest a name',
                    onPressed: () {
                      _controller.text = generateGuestNickname();
                    },
                  ),
                ),
                onSubmitted: (_) => _continue(),
              ),

              if (_error != null) ...[
                const SizedBox(height: AuxSpacing.sm),
                Text(
                  _error!,
                  style: AuxTypography.caption.copyWith(color: AuxColors.danger),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: AuxSpacing.xl),

              // ── Continue button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuxColors.signalTeal,
                    foregroundColor: AuxColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AuxColors.ink,
                          ),
                        )
                      : Text(
                          'Let\'s Go',
                          style: AuxTypography.button.copyWith(color: AuxColors.ink),
                        ),
                ),
              ),

              const SizedBox(height: AuxSpacing.md),

              // ── Back to login ──
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Back to login',
                  style: AuxTypography.caption.copyWith(color: AuxColors.paperMuted),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
