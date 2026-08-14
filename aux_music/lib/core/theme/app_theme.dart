import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// Builds the full ThemeData for Aux — dark and light variants.
abstract final class AuxTheme {
  // ── Dark Theme (default) ─────────────────────────────────────────
  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        bg: AuxColors.ink,
        surface: AuxColors.inkRaised,
        border: AuxColors.hairline,
        text: AuxColors.paper,
        textMuted: AuxColors.paperMuted,
      );

  // ── Light Theme ──────────────────────────────────────────────────
  static ThemeData get light => _build(
        brightness: Brightness.light,
        bg: AuxColorsLight.ink,
        surface: AuxColorsLight.inkRaised,
        border: AuxColorsLight.hairline,
        text: AuxColorsLight.paper,
        textMuted: AuxColorsLight.paperMuted,
      );

  // ─────────────────────────────────────────────────────────────────
  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color border,
    required Color text,
    required Color textMuted,
  }) {
    final isDark = brightness == Brightness.dark;

    // System overlay (status bar / nav bar)
    final systemOverlay = isDark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: bg,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: bg,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      extensions: [
        isDark ? AuxThemeColors.dark : AuxThemeColors.light,
      ],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AuxColors.ember,
        onPrimary: Colors.white,
        primaryContainer: AuxColors.ember.withValues(alpha: 0.18),
        onPrimaryContainer: AuxColors.ember,
        secondary: AuxColors.signalTeal,
        onSecondary: AuxColors.ink,
        secondaryContainer: AuxColors.signalTeal.withValues(alpha: 0.18),
        onSecondaryContainer: AuxColors.signalTeal,
        surface: surface,
        onSurface: text,
        surfaceContainerHighest: surface,
        onSurfaceVariant: textMuted,
        outline: border,
        outlineVariant: border.withValues(alpha: 0.5),
        error: AuxColors.danger,
        onError: Colors.white,
        shadow: Colors.black,
        scrim: Colors.black54,
        inverseSurface: text,
        onInverseSurface: bg,
        inversePrimary: AuxColors.emberSoft,
      ),
      textTheme: AuxTypography.buildTextTheme(primaryColor: text),

      // ── AppBar ─────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: systemOverlay,
        titleTextStyle: AuxTypography.titleLg.copyWith(color: text),
        iconTheme: IconThemeData(color: text),
        actionsIconTheme: IconThemeData(color: textMuted),
      ),

      // ── Bottom Navigation Bar ──────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: AuxColors.ember.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AuxColors.ember, size: 24);
          }
          return IconThemeData(color: textMuted, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final style = AuxTypography.navLabel;
          if (states.contains(WidgetState.selected)) {
            return style.copyWith(color: AuxColors.ember);
          }
          return style.copyWith(color: textMuted);
        }),
        height: AuxSpacing.bottomNavHeight,
        elevation: 0,
      ),

      // ── Cards ──────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Input / Search ─────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AuxSpacing.lg,
          vertical: AuxSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
          borderSide: BorderSide.none,
        ),
        hintStyle: AuxTypography.body.copyWith(color: textMuted),
        prefixIconColor: textMuted,
      ),

      // ── Elevated Button ────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AuxColors.ember,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AuxSpacing.xl,
            vertical: AuxSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
          ),
          textStyle: AuxTypography.button,
          minimumSize: const Size(0, AuxSpacing.minTapTarget),
        ),
      ),

      // ── Text Button ────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AuxColors.ember,
          textStyle: AuxTypography.button,
          minimumSize: const Size(0, AuxSpacing.minTapTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AuxSpacing.lg,
            vertical: AuxSpacing.sm,
          ),
        ),
      ),

      // ── Outlined Button ────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: BorderSide(color: border),
          textStyle: AuxTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuxSpacing.radiusCard),
          ),
          minimumSize: const Size(0, AuxSpacing.minTapTarget),
        ),
      ),

      // ── FAB (Play/Pause) ───────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AuxColors.ember,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ── Chips ─────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: AuxColors.ember.withValues(alpha: 0.18),
        labelStyle: AuxTypography.captionMedium.copyWith(color: text),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuxSpacing.md),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AuxSpacing.md,
          vertical: AuxSpacing.xs,
        ),
      ),

      // ── Bottom Sheet ───────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AuxSpacing.radiusSheet),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: textMuted.withValues(alpha: 0.4),
      ),

      // ── Dialog ─────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuxSpacing.radiusSheet),
        ),
        titleTextStyle: AuxTypography.titleLg.copyWith(color: text),
        contentTextStyle: AuxTypography.body.copyWith(color: textMuted),
      ),

      // ── Slider (progress, volume, EQ) ─────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: AuxColors.ember,
        inactiveTrackColor: border,
        thumbColor: Colors.white,
        overlayColor: AuxColors.ember.withValues(alpha: 0.12),
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      ),

      // ── Switch ─────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AuxColors.signalTeal;
          }
          return border;
        }),
      ),

      // ── Divider ────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      // ── List Tile ──────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AuxSpacing.lg,
          vertical: AuxSpacing.xs,
        ),
        minLeadingWidth: 0,
        minVerticalPadding: AuxSpacing.sm,
      ),

      // ── Progress Indicator ─────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AuxColors.ember,
        linearTrackColor: Color(0xFF26262F),
      ),

      // ── Icon ───────────────────────────────────────────────────
      iconTheme: IconThemeData(color: text, size: 24),

      // ── Tooltip ────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AuxSpacing.sm),
        ),
        textStyle: AuxTypography.caption.copyWith(color: text),
      ),
    );
  }
}
