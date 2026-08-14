import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A deterministic waveform visualizer that generates bars based on a seed (like track ID).
/// It reacts to the current playback position without doing real-time FFT audio analysis,
/// saving battery and performance.
class WaveformVisualizer extends StatelessWidget {
  const WaveformVisualizer({
    super.key,
    required this.seed,
    required this.progress,
    this.height = 40,
    this.barWidth = 4.0,
    this.spacing = 2.0,
  });

  final String seed;
  final double progress; // 0.0 to 1.0
  final double height;
  final double barWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barCount = (constraints.maxWidth / (barWidth + spacing)).floor();
          if (barCount <= 0) return const SizedBox.shrink();

          return CustomPaint(
            size: Size(constraints.maxWidth, height),
            painter: _WaveformPainter(
              seed: seed,
              progress: progress,
              barCount: barCount,
              barWidth: barWidth,
              spacing: spacing,
              inactiveColor: context.colors.paperMuted.withValues(alpha: 0.3),
            ),
          );
        },
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.seed,
    required this.progress,
    required this.barCount,
    required this.barWidth,
    required this.spacing,
    required this.inactiveColor,
  });

  final String seed;
  final double progress;
  final int barCount;
  final double barWidth;
  final double spacing;
  final Color inactiveColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Generate deterministic heights using a basic hash of the seed
    final random = math.Random(seed.hashCode);
    
    final paintActive = Paint()
      ..color = AuxColors.ember
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final paintInactive = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final activeBars = (progress * barCount).floor();

    for (int i = 0; i < barCount; i++) {
      // Create a curve so the middle is generally taller, like a real track waveform
      final normalizedIndex = i / barCount;
      final envelope = math.sin(normalizedIndex * math.pi); // 0 at edges, 1 at center
      
      // Add noise
      final noise = 0.3 + (random.nextDouble() * 0.7); 
      
      final barHeight = size.height * envelope * noise;
      // Ensure minimum height
      final finalHeight = math.max(barHeight, 4.0);

      final x = i * (barWidth + spacing);
      final y = (size.height - finalHeight) / 2; // Center vertically

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, finalHeight),
        Radius.circular(barWidth / 2),
      );

      canvas.drawRRect(rect, i < activeBars ? paintActive : paintInactive);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.seed != seed ||
           oldDelegate.barCount != barCount;
  }
}
