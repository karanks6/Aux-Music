import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../services/auth_service.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    
    if (password != confirmPassword) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await ref.read(authServiceProvider).signUpWithEmail(email, password, name);
      if (user != null && mounted) {
        context.go('/verify-email');
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.colors.paper),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              const SizedBox(height: AuxSpacing.lg),
              Text(
                'Create Account',
                style: AuxTypography.display.copyWith(color: context.colors.paper, fontSize: 32),
              ),
              const SizedBox(height: AuxSpacing.xs),
              Text(
                'Join the party and start listening.',
                style: AuxTypography.body.copyWith(color: context.colors.paperMuted),
              ),
              const SizedBox(height: AuxSpacing.xxl),

              // ── Name Field ──
              TextField(
                controller: _nameController,
                style: AuxTypography.body.copyWith(color: context.colors.paper),
                decoration: InputDecoration(
                  hintText: 'Display Name',
                  hintStyle: AuxTypography.body.copyWith(color: context.colors.paperMuted),
                  filled: true,
                  fillColor: context.colors.inkRaised,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AuxSpacing.md),

              // ── Email Field ──
              TextField(
                controller: _emailController,
                style: AuxTypography.body.copyWith(color: context.colors.paper),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: AuxTypography.body.copyWith(color: context.colors.paperMuted),
                  filled: true,
                  fillColor: context.colors.inkRaised,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AuxSpacing.md),

              // ── Password Field ──
              TextField(
                controller: _passwordController,
                style: AuxTypography.body.copyWith(color: context.colors.paper),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: AuxTypography.body.copyWith(color: context.colors.paperMuted),
                  filled: true,
                  fillColor: context.colors.inkRaised,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                obscureText: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AuxSpacing.md),

              // ── Confirm Password Field ──
              TextField(
                controller: _confirmPasswordController,
                style: AuxTypography.body.copyWith(color: context.colors.paper),
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  hintStyle: AuxTypography.body.copyWith(color: context.colors.paperMuted),
                  filled: true,
                  fillColor: context.colors.inkRaised,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _signUp(),
              ),

              const SizedBox(height: AuxSpacing.xl),

              // ── Sign Up Button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
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
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: context.colors.ink),
                        )
                      : Text('Sign up',
                          style: AuxTypography.button
                              .copyWith(fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: AuxSpacing.lg),

              // ── Error ──
              if (_error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AuxSpacing.md, vertical: AuxSpacing.sm),
                  decoration: BoxDecoration(
                    color: AuxColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _error!,
                    style: AuxTypography.caption
                        .copyWith(color: AuxColors.danger),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: AuxSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
