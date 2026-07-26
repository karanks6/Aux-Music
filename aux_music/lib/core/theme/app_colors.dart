import 'package:flutter/material.dart';

/// Aux design token colors — Section 5.3 of the product spec.
/// Dark-first; [AuxColors] = dark theme. [AuxColorsLight] = light theme.
/// Ember and Teal remain constant across both themes.
abstract final class AuxColors {
  // ── Base backgrounds ────────────────────────────────────────────
  /// Base background — near-black (#0D0D12)
  static const Color ink = Color(0xFF0D0D12);

  /// Raised surfaces — cards, sheets (#17171F)
  static const Color inkRaised = Color(0xFF17171F);

  /// Dividers and borders
  static const Color hairline = Color(0xFF26262F);

  // ── Accents — constant across themes ────────────────────────────
  /// Primary accent — CTAs, active nav, progress fill (#FF6B35)
  static const Color ember = Color(0xFFFF6B35);

  /// Pressed / hover state (#FF8C5A)
  static const Color emberSoft = Color(0xFFFF8C5A);

  /// Secondary accent — waveforms, links, toggle on (#2DD4BF)
  static const Color signalTeal = Color(0xFF2DD4BF);

  // ── Text ────────────────────────────────────────────────────────
  /// Primary text
  static const Color paper = Color(0xFFF5F3EF);

  /// Secondary / muted text
  static const Color paperMuted = Color(0xFF9A98A3);

  // ── Status — never used as branding ─────────────────────────────
  /// Downloaded, success states
  static const Color positive = Color(0xFF4ADE80);

  /// Errors
  static const Color danger = Color(0xFFF87171);

  // ── Gradients ───────────────────────────────────────────────────
  /// Signal → Ember gradient (used for the Now Playing pulse ring)
  static const LinearGradient signalToEmberGradient = LinearGradient(
    colors: [signalTeal, ember],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Warm radial background for Now Playing screen
  static RadialGradient nowPlayingRadialGradient(Color dominantColor) {
    return RadialGradient(
      center: Alignment.topCenter,
      radius: 1.2,
      colors: [
        dominantColor.withValues(alpha: 0.35),
        ink,
      ],
    );
  }
}

/// Light-mode overrides. Ember and Teal stay constant (still premium on warm off-white).
abstract final class AuxColorsLight {
  static const Color ink = Color(0xFFFAF9F6);
  static const Color inkRaised = Color(0xFFEFEDE8);
  static const Color hairline = Color(0xFFDDDCD8);
  static const Color paper = Color(0xFF141417);
  static const Color paperMuted = Color(0xFF5A5869);

  // Shared with dark — identical
  static const Color ember = AuxColors.ember;
  static const Color emberSoft = AuxColors.emberSoft;
  static const Color signalTeal = AuxColors.signalTeal;
  static const Color positive = AuxColors.positive;
  static const Color danger = AuxColors.danger;
}

/// High-contrast overrides for accessibility.
abstract final class AuxColorsHighContrast {
  static const Color ink = Color(0xFF000000);
  static const Color inkRaised = Color(0xFF0A0A0A);
  static const Color hairline = Color(0xFF444444);
  static const Color paper = Color(0xFFFFFFFF);
  static const Color paperMuted = Color(0xFFCCCCCC);

  static const Color ember = Color(0xFFFF7A4A); // slightly brighter for contrast
  static const Color signalTeal = Color(0xFF33E8D4);
}
