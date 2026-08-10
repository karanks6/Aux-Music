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
    _fadeCtrl.dispose();
    super.dispose();
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
          _error = 'Sign in failed. Please try again.';
        });
      }
    }
  }

  void _continueAsGuest() {
    context.push('/nickname');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuxColors.ink,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AuxSpacing.xl),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Logo / Wordmark ──
                _AuxLogo(),

                const SizedBox(height: AuxSpacing.sm),

                Text(
                  'Free music. No limits.',
                  style: AuxTypography.body.copyWith(
                    color: AuxColors.paperMuted,
                    letterSpacing: 0.3,
                  ),
                ),

                const Spacer(flex: 2),

                // ── Sign in with Google ──
                _GoogleSignInButton(
                  isLoading: _isLoading,
                  onTap: _isLoading ? null : _signInWithGoogle,
                ),

                const SizedBox(height: AuxSpacing.md),

                // ── Continue as Guest ──
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _continueAsGuest,
                    icon: const Icon(Icons.person_outline_rounded,
                        size: 20, color: AuxColors.paperMuted),
                    label: Text(
                      'Continue as Guest',
                      style: AuxTypography.button.copyWith(
                          color: AuxColors.paperMuted),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AuxColors.hairline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                // ── Error ──
                if (_error != null) ...[
                  const SizedBox(height: AuxSpacing.md),
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
                ],

                const Spacer(flex: 1),

                // ── Fine print ──
                Text(
                  'By continuing you agree to our Terms of Service.\nYour data stays on your device.',
                  style: AuxTypography.caption
                      .copyWith(color: AuxColors.paperMuted.withValues(alpha: 0.5)),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AuxSpacing.xl),
              ],
            ),
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
        // Glowing icon
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AuxColors.ember.withValues(alpha: 0.35),
                AuxColors.ember.withValues(alpha: 0.0),
              ],
            ),
          ),
          child: Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AuxColors.inkRaised,
                border:
                    Border.all(color: AuxColors.ember.withValues(alpha: 0.5), width: 1.5),
              ),
              child: const Icon(
                Icons.headphones_rounded,
                color: AuxColors.ember,
                size: 30,
              ),
            ),
          ),
        ),
        const SizedBox(height: AuxSpacing.lg),
        Text(
          'Aux',
          style: AuxTypography.display.copyWith(
            color: AuxColors.ember,
            fontSize: 52,
            fontWeight: FontWeight.bold,
            letterSpacing: -2,
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
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google "G" icon
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

    // Draw 4 colored arcs for the Google "G"
    final colors = [
      const Color(0xFF4285F4), // Blue (top)
      const Color(0xFFEA4335), // Red (right)
      const Color(0xFFFBBC05), // Yellow (bottom)
      const Color(0xFF34A853), // Green (left)
    ];

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22;

    const sweep = 3.14159 * 0.5; // 90°

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

    // White cutout on the right for the horizontal bar
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
