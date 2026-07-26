import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Aux typography system — Section 5.4 of the product spec.
///
/// - Display: Fraunces (large sizes only — never body or dense lists)
/// - Body/UI: Sora (with tabular figures for duration/progress)
/// - Multi-script: Noto Sans via google_fonts per active locale
///
/// Type scale:
///   Display  32/40
///   Title    22/28
///   Body     15/22
///   Caption  12/16
abstract final class AuxTypography {
  // ─────────────────────────────────────────────────────────────────
  // Display — Fraunces only at display sizes
  // ─────────────────────────────────────────────────────────────────

  /// Track titles, playlist headers, Year-on-Aux big numbers.
  static TextStyle get display => GoogleFonts.fraunces(
        fontSize: 32,
        height: 40 / 32, // 40px line-height
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  /// Slightly smaller display — e.g. Now Playing track title
  static TextStyle get displaySm => GoogleFonts.fraunces(
        fontSize: 26,
        height: 34 / 26,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      );

  // ─────────────────────────────────────────────────────────────────
  // Title — Sora
  // ─────────────────────────────────────────────────────────────────

  static TextStyle get titleLg => GoogleFonts.sora(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleMd => GoogleFonts.sora(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w600,
      );

  // ─────────────────────────────────────────────────────────────────
  // Body — Sora
  // ─────────────────────────────────────────────────────────────────

  static TextStyle get bodyLg => GoogleFonts.sora(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get body => GoogleFonts.sora(
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodySemiBold => GoogleFonts.sora(
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w600,
      );

  // ─────────────────────────────────────────────────────────────────
  // Caption — Sora
  // ─────────────────────────────────────────────────────────────────

  static TextStyle get caption => GoogleFonts.sora(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get captionMedium => GoogleFonts.sora(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
      );

  // ─────────────────────────────────────────────────────────────────
  // Tabular figures — for track durations and progress timers
  // Sora supports OpenType `tnum` feature for non-jittering digits.
  // ─────────────────────────────────────────────────────────────────

  static TextStyle get tabularDuration => GoogleFonts.sora(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle get tabularProgress => GoogleFonts.sora(
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w400,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // ─────────────────────────────────────────────────────────────────
  // Button labels
  // ─────────────────────────────────────────────────────────────────

  static TextStyle get button => GoogleFonts.sora(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  static TextStyle get buttonSm => GoogleFonts.sora(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  // ─────────────────────────────────────────────────────────────────
  // Nav / label
  // ─────────────────────────────────────────────────────────────────

  static TextStyle get navLabel => GoogleFonts.sora(
        fontSize: 10,
        height: 14 / 10,
        fontWeight: FontWeight.w500,
      );

  // ─────────────────────────────────────────────────────────────────
  // TextTheme for ThemeData
  // ─────────────────────────────────────────────────────────────────

  static TextTheme buildTextTheme({required Color primaryColor}) {
    return TextTheme(
      displayLarge: display.copyWith(color: primaryColor),
      displayMedium: displaySm.copyWith(color: primaryColor),
      titleLarge: titleLg.copyWith(color: primaryColor),
      titleMedium: titleMd.copyWith(color: primaryColor),
      bodyLarge: bodyLg.copyWith(color: primaryColor),
      bodyMedium: body.copyWith(color: primaryColor),
      bodySmall: caption.copyWith(color: primaryColor.withValues(alpha: 0.7)),
      labelLarge: button.copyWith(color: primaryColor),
      labelSmall: navLabel.copyWith(color: primaryColor),
    );
  }
}
