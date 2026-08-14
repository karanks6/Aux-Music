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
  static RadialGradient nowPlayingRadialGradient(Color dominantColor, Color bgColor) {
    return RadialGradient(
      center: Alignment.topCenter,
      radius: 1.2,
      colors: [
        dominantColor.withValues(alpha: 0.35),
        bgColor,
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

class AuxThemeColors extends ThemeExtension<AuxThemeColors> {
  const AuxThemeColors({
    required this.ink,
    required this.inkRaised,
    required this.hairline,
    required this.paper,
    required this.paperMuted,
  });

  final Color ink;
  final Color inkRaised;
  final Color hairline;
  final Color paper;
  final Color paperMuted;

  @override
  AuxThemeColors copyWith({
    Color? ink,
    Color? inkRaised,
    Color? hairline,
    Color? paper,
    Color? paperMuted,
  }) {
    return AuxThemeColors(
      ink: ink ?? this.ink,
      inkRaised: inkRaised ?? this.inkRaised,
      hairline: hairline ?? this.hairline,
      paper: paper ?? this.paper,
      paperMuted: paperMuted ?? this.paperMuted,
    );
  }

  @override
  AuxThemeColors lerp(ThemeExtension<AuxThemeColors>? other, double t) {
    if (other is! AuxThemeColors) return this;
    return AuxThemeColors(
      ink: Color.lerp(ink, other.ink, t)!,
      inkRaised: Color.lerp(inkRaised, other.inkRaised, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      paper: Color.lerp(paper, other.paper, t)!,
      paperMuted: Color.lerp(paperMuted, other.paperMuted, t)!,
    );
  }

  static const dark = AuxThemeColors(
    ink: AuxColors.ink,
    inkRaised: AuxColors.inkRaised,
    hairline: AuxColors.hairline,
    paper: AuxColors.paper,
    paperMuted: AuxColors.paperMuted,
  );

  static const light = AuxThemeColors(
    ink: AuxColorsLight.ink,
    inkRaised: AuxColorsLight.inkRaised,
    hairline: AuxColorsLight.hairline,
    paper: AuxColorsLight.paper,
    paperMuted: AuxColorsLight.paperMuted,
  );
}

extension AuxColorsExtension on BuildContext {
  AuxThemeColors get colors => Theme.of(this).extension<AuxThemeColors>() ?? AuxThemeColors.dark;
}
