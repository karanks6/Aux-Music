import 'package:flutter/material.dart';
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
import '../../data/models/podcast.dart';

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
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// The app's route configuration.
/// Uses [ShellRoute] to preserve the persistent bottom nav + mini-player
/// scaffold across all main feature routes.
final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.home,
  routes: [
    // ── Shell (persistent scaffold with nav + mini-player) ─────────
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.search,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SearchScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.library,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LibraryScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.podcasts,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PodcastsScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.social,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SocialScreen(),
          ),
        ),
        // Artist / album / playlist — stay inside the shell (back = pop)
        GoRoute(
          path: AppRoutes.artist,
          builder: (context, state) => ArtistPageScreen(
            artistId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: AppRoutes.album,
          builder: (context, state) => AlbumPageScreen(
            albumId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: AppRoutes.playlist,
          builder: (context, state) => PlaylistDetailScreen(
            playlistId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: AppRoutes.podcastDetail,
          builder: (context, state) {
            final podcast = state.extra as Podcast?;
            return PodcastDetailScreen(
              podcastId: state.pathParameters['id']!,
              podcast: podcast,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.passTheAux,
          builder: (context, state) => const PassTheAuxScreen(),
        ),
      ],
    ),

    // ── Full-screen routes (no bottom nav) ─────────────────────────
    GoRoute(
      path: AppRoutes.nowPlaying,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        opaque: false, // Allows seeing the screen below during swipe-down
        child: const NowPlayingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide up from bottom — mirrors the mini-player expand gesture
          const begin = Offset(0, 1);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end).chain(
            CurveTween(
              curve: const Cubic(0.2, 0.0, 0.0, 1.0), // decelerate
            ),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ),
    GoRoute(
      path: AppRoutes.queue,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        opaque: false,
        child: const QueueScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0, 1);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: const Cubic(0.2, 0.0, 0.0, 1.0)),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ),
    GoRoute(
      path: AppRoutes.settings,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.socialSession,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => SocialScreen(
        sessionCode: state.pathParameters['code'],
      ),
    ),
  ],
);

/// The persistent shell scaffold — bottom nav + mini-player docked above it.
/// Child is the current page from the ShellRoute.
class _AppShell extends StatelessWidget {
  const _AppShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini-player sits directly above the bottom nav bar
          const MiniPlayerWidget(),
          _BottomNav(),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int selectedIndex = 0;
    if (location.startsWith('/search')) {
      selectedIndex = 1;
    } else if (location.startsWith('/library')) {
      selectedIndex = 2;
    } else if (location.startsWith('/podcasts')) {
      selectedIndex = 3;
    } else if (location.startsWith('/social')) {
      selectedIndex = 4;
    }

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go(AppRoutes.home);
          case 1:
            context.go(AppRoutes.search);
          case 2:
            context.go(AppRoutes.library);
          case 3:
            context.go(AppRoutes.podcasts);
          case 4:
            context.go(AppRoutes.social);
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.search_rounded),
          selectedIcon: Icon(Icons.search_rounded),
          label: 'Search',
        ),
        NavigationDestination(
          icon: Icon(Icons.library_music_outlined),
          selectedIcon: Icon(Icons.library_music_rounded),
          label: 'Library',
        ),
        NavigationDestination(
          icon: Icon(Icons.podcasts_outlined),
          selectedIcon: Icon(Icons.podcasts_rounded),
          label: 'Podcasts',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outlined),
          selectedIcon: Icon(Icons.people_rounded),
          label: 'Pass the Aux',
        ),
      ],
    );
  }
}
