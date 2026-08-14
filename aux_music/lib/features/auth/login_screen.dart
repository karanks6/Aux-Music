import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter both email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await ref.read(authServiceProvider).signInWithEmail(email, password);
      if (user != null && mounted) {
        if (!user.emailVerified) {
          context.go('/verify-email');
        } else {
          context.go('/');
        }
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

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = await ref.read(authServiceProvider).signInWithGoogle();
      if (user != null && mounted) {
        context.go('/');
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Google Sign-in failed. Please ensure your SHA-1 key is registered in Firebase.\nError: ${e.toString().split('\n').first}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.ink,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                const SizedBox(height: AuxSpacing.xxl),

                // ── Logo / Wordmark ──
                _AuxLogo(),

                const SizedBox(height: AuxSpacing.sm),

                Text(
                  'Free music. No limits.',
                  style: AuxTypography.body.copyWith(
                    color: context.colors.paperMuted,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: AuxSpacing.xxl),

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
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _signInWithEmail(),
                ),

                const SizedBox(height: AuxSpacing.lg),

                // ── Login Button ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signInWithEmail,
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
                        : Text('Log in',
                            style: AuxTypography.button
                                .copyWith(fontWeight: FontWeight.w600)),
                  ),
                ),

                const SizedBox(height: AuxSpacing.md),

                // ── Google Sign in ──
                _GoogleSignInButton(
                  isLoading: _isLoading,
                  onTap: _isLoading ? null : _signInWithGoogle,
                ),

                const SizedBox(height: AuxSpacing.lg),

                // ── Error ──
                if (_error != null) ...[
                  Container(
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
                  const SizedBox(height: AuxSpacing.lg),
                ],

                // ── Sign Up Link ──
                TextButton(
                  onPressed: _isLoading ? null : () => context.push('/signup'),
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: AuxTypography.body.copyWith(color: context.colors.paperMuted),
                      children: [
                        TextSpan(
                          text: 'Sign up',
                          style: AuxTypography.body.copyWith(
                            color: AuxColors.ember,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AuxSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Aux Logo ──────────────────────────────────────────────────────────────────

class _AuxLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/icons/Aux_applogo.png',
          width: 100,
          height: 100,
        ),
        const SizedBox(height: AuxSpacing.sm),
        Text(
          'Aux',
          style: AuxTypography.display.copyWith(
            color: AuxColors.ember,
            fontSize: 48,
            fontWeight: FontWeight.bold,
            letterSpacing: -1.5,
          ),
        ),
      ],
    );
  }
}

// ── Google Sign-In Button ─────────────────────────────────────────────────────

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({required this.isLoading, required this.onTap});
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _GoogleGIcon(),
                const SizedBox(width: 12),
                const Text(
                  'Sign in with Google',
                  style: TextStyle(
                    color: Color(0xFF1F1F1F),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleGIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = rect.center;
    final radius = size.width / 2;

    final colors = [
      const Color(0xFF4285F4),
      const Color(0xFFEA4335),
      const Color(0xFFFBBC05),
      const Color(0xFF34A853),
    ];

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22;

    const sweep = 3.14159 * 0.5;

    for (int i = 0; i < 4; i++) {
      paint.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.75),
        -3.14159 / 2 + i * sweep,
        sweep,
        false,
        paint,
      );
    }

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - size.height * 0.13,
          radius * 0.75, size.height * 0.26),
      whitePaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
