import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/di/providers.dart';
import 'core/providers/library_providers.dart';
import 'services/auth_service.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Root application widget.
class AuxApp extends ConsumerWidget {
  const AuxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    // Watch auth state so we rebuild when user signs in/out
    ref.watch(authStateProvider);
    
    // Sync local library with Firestore when auth state changes
    ref.listen(authStateProvider, (previous, next) {
      final user = next.valueOrNull;
      final repo = ref.read(libraryRepositoryProvider);
      if (user != null) {
        repo.syncUserLibrary(user.uid);
      } else if (previous?.valueOrNull != null) {
        repo.clearUserData();
      }
    });
    
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Aux',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,

      // ── Themes ──────────────────────────────────────────────────
      theme: AuxTheme.light,
      darkTheme: AuxTheme.dark,
      themeMode: themeMode,

      // ── Router ──────────────────────────────────────────────────
      routerConfig: router,

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

      // ── Builder (media query overrides) ─────────────────────────
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
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
