import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/now_playing/now_playing_screen.dart';
import '../../features/now_playing/queue_screen.dart';
import '../../features/artist_page/artist_page_screen.dart';
import '../../features/album_page/album_page_screen.dart';
import '../../features/playlist_detail/playlist_detail_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/social/social_screen.dart';
import '../../features/podcasts/podcasts_screen.dart';
import '../../features/podcasts/podcast_detail_screen.dart';
import '../../features/player_mini/mini_player_widget.dart';
import '../../features/pass_the_aux/pass_the_aux_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/nickname_screen.dart';
import '../../data/models/podcast.dart';
import '../../services/auth_service.dart';

// Route path constants
abstract final class AppRoutes {
  static const home = '/';
  static const search = '/search';
  static const library = '/library';
  static const podcasts = '/podcasts';
  static const social = '/social';
  static const nowPlaying = '/now-playing';
  static const queue = '/queue';
  static const artist = '/artist/:id';
  static const album = '/album/:id';
  static const playlist = '/playlist/:id';
  static const podcastDetail = '/podcast/:id';
  static const settings = '/settings';
  static const socialSession = '/social/session/:code';
  static const passTheAux = '/pass-the-aux';
  static const login = '/login';
  static const nickname = '/nickname';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// A [ChangeNotifier] that re-notifies when auth state changes.
/// Used as [GoRouter.refreshListenable] so the router re-evaluates redirects.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}

final _authChangeNotifierProvider = Provider<_AuthChangeNotifier>((ref) {
  return _AuthChangeNotifier(ref);
});

/// The single app router, built once per ProviderScope.
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(_authChangeNotifierProvider);
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    refreshListenable: notifier,
    redirect: (context, state) {
      final user = ref.read(authStateProvider).valueOrNull;
      final isAuthenticated = user != null;
      final loc = state.matchedLocation;
      final isGoingToAuth =
          loc == AppRoutes.login || loc == AppRoutes.nickname;

      if (!isAuthenticated && !isGoingToAuth) return AppRoutes.login;
      if (isAuthenticated && loc == AppRoutes.login) return AppRoutes.home;
      return null;
    },
    routes: [
      // ── Auth Routes (full screen, no shell) ──────────────────────
      GoRoute(
        path: AppRoutes.login,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.nickname,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const NicknameScreen(),
      ),

      // ── Shell (persistent scaffold) ──────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => _AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (_, state) =>
                NoTransitionPage(key: state.pageKey, child: const HomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.search,
            pageBuilder: (_, state) => NoTransitionPage(
                key: state.pageKey, child: const SearchScreen()),
          ),
          GoRoute(
            path: AppRoutes.library,
            pageBuilder: (_, state) => NoTransitionPage(
                key: state.pageKey, child: const LibraryScreen()),
          ),
          GoRoute(
            path: AppRoutes.podcasts,
            pageBuilder: (_, state) => NoTransitionPage(
                key: state.pageKey, child: const PodcastsScreen()),
          ),
          GoRoute(
            path: AppRoutes.social,
            pageBuilder: (_, state) => NoTransitionPage(
                key: state.pageKey, child: const SocialScreen()),
          ),
          GoRoute(
            path: AppRoutes.artist,
            builder: (_, state) =>
                ArtistPageScreen(artistId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: AppRoutes.album,
            builder: (_, state) =>
                AlbumPageScreen(albumId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: AppRoutes.playlist,
            builder: (_, state) =>
                PlaylistDetailScreen(playlistId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: AppRoutes.podcastDetail,
            builder: (_, state) =>
                PodcastDetailScreen(podcast: state.extra as Podcast),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (_, __) => const SettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.passTheAux,
            pageBuilder: (_, state) => NoTransitionPage(
                key: state.pageKey, child: const PassTheAuxScreen()),
          ),
        ],
      ),

      // ── Full-screen overlays (no bottom nav) ────────────────────
      GoRoute(
        path: AppRoutes.nowPlaying,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (_, state) => CustomTransitionPage(
          opaque: false,
          child: const NowPlayingScreen(),
          transitionsBuilder: (context, animation, _, child) {
            return SlideTransition(
              position: Tween(
                      begin: const Offset(0, 1), end: Offset.zero)
                  .chain(CurveTween(curve: const Cubic(0.2, 0.0, 0.0, 1.0)))
                  .animate(animation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: AppRoutes.queue,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (_, state) => CustomTransitionPage(
          opaque: false,
          child: const QueueScreen(),
          transitionsBuilder: (context, animation, _, child) {
            return SlideTransition(
              position: Tween(
                      begin: const Offset(0, 1), end: Offset.zero)
                  .chain(CurveTween(curve: const Cubic(0.2, 0.0, 0.0, 1.0)))
                  .animate(animation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.socialSession,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) =>
            SocialScreen(sessionCode: state.pathParameters['code']),
      ),
    ],
  );
});

// Convenience alias used in app.dart
GoRouter buildAppRouter(WidgetRef ref) => ref.read(appRouterProvider);

/// The persistent shell scaffold — bottom nav + mini-player docked above it.
class _AppShell extends StatelessWidget {
  const _AppShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final isHome = location == AppRoutes.home;

    return PopScope(
      canPop: isHome,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go(AppRoutes.home);
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MiniPlayerWidget(),
            _BottomNav(),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int selectedIndex = 0;
    if (location.startsWith('/search')) selectedIndex = 1;
    else if (location.startsWith('/library')) selectedIndex = 2;
    else if (location.startsWith('/podcasts')) selectedIndex = 3;
    else if (location.startsWith('/pass-the-aux') ||
        location.startsWith('/social')) selectedIndex = 4;

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0: context.go(AppRoutes.home);
          case 1: context.go(AppRoutes.search);
          case 2: context.go(AppRoutes.library);
          case 3: context.go(AppRoutes.podcasts);
          case 4: context.go(AppRoutes.passTheAux);
        }
      },
      destinations: const [
        NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home'),
        NavigationDestination(
            icon: Icon(Icons.search_rounded),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Search'),
        NavigationDestination(
            icon: Icon(Icons.library_music_outlined),
            selectedIcon: Icon(Icons.library_music_rounded),
            label: 'Library'),
        NavigationDestination(
            icon: Icon(Icons.podcasts_outlined),
            selectedIcon: Icon(Icons.podcasts_rounded),
            label: 'Podcasts'),
        NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Pass the Aux'),
      ],
    );
  }
}
