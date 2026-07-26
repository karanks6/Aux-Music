import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/di/providers.dart';

/// Root application widget.
class AuxApp extends ConsumerWidget {
  const AuxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Aux',
      debugShowCheckedModeBanner: false,

      // ── Themes ──────────────────────────────────────────────────
      theme: AuxTheme.light,
      darkTheme: AuxTheme.dark,
      themeMode: themeMode,

      // ── Router ──────────────────────────────────────────────────
      routerConfig: appRouter,

      // ── Localization ────────────────────────────────────────────
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), Locale('hi'), Locale('kn'), Locale('ml'),
        Locale('ta'), Locale('te'), Locale('bn'), Locale('pa'),
        Locale('mr'), Locale('gu'), Locale('ur'), Locale('es'),
        Locale('ru'), Locale('fr'), Locale('de'), Locale('pt'),
        Locale('ar'), Locale('ja'), Locale('ko'), Locale('zh'),
      ],

      // ── Builder (media query overrides, system chrome) ──────────
      builder: (context, child) {
        // Respect system-level text scaling
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            // Cap text scale to prevent layout breaks beyond 1.5×
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.5,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
