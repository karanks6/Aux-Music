import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../services/auth_service.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _isLoading = false;
  String? _message;
  bool _isError = false;

  void _showMessage(String msg, {bool isError = false}) {
    setState(() {
      _message = msg;
      _isError = isError;
    });
  }

  Future<void> _checkVerification() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      await auth.reloadUser();
      if (auth.isEmailVerified) {
        if (mounted) context.go('/');
      } else {
        _showMessage('Email is not verified yet. Please check your inbox.', isError: true);
      }
    } catch (e) {
      _showMessage('Failed to verify status.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendEmail() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await ref.read(authServiceProvider).sendEmailVerification();
      _showMessage('Verification email sent! Check your inbox.');
    } catch (e) {
      _showMessage('Failed to send verification email.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await ref.read(authServiceProvider).signOut();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.mark_email_unread_rounded,
                color: AuxColors.ember,
                size: 80,
              ),
              const SizedBox(height: AuxSpacing.xl),
              Text(
                'Verify your email',
                style: AuxTypography.display.copyWith(color: context.colors.paper, fontSize: 32),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AuxSpacing.md),
              Text(
                'We\'ve sent a verification link to your email address. Please click the link to activate your account.',
                style: AuxTypography.body.copyWith(color: context.colors.paperMuted, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AuxSpacing.xxl),

              // ── Buttons ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _checkVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuxColors.ember,
                    foregroundColor: context.colors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: context.colors.ink),
                        )
                      : Text('I\'ve Verified', style: AuxTypography.button.copyWith(fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: AuxSpacing.md),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _resendEmail,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: context.colors.hairline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Resend Email',
                    style: AuxTypography.button.copyWith(color: context.colors.paper),
                  ),
                ),
              ),

              const SizedBox(height: AuxSpacing.xl),
              
              if (_message != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.md, vertical: AuxSpacing.sm),
                  decoration: BoxDecoration(
                    color: _isError 
                        ? AuxColors.danger.withValues(alpha: 0.1)
                        : AuxColors.signalTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _message!,
                    style: AuxTypography.caption.copyWith(
                      color: _isError ? AuxColors.danger : AuxColors.signalTeal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              
              const Spacer(),
              
              TextButton(
                onPressed: _isLoading ? null : _signOut,
                child: Text(
                  'Cancel and Sign out',
                  style: AuxTypography.body.copyWith(color: context.colors.paperMuted),
                ),
              ),
              const SizedBox(height: AuxSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
