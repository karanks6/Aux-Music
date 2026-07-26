// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Aux';

  @override
  String get greeting_morning => 'Good morning';

  @override
  String get greeting_afternoon => 'Good afternoon';

  @override
  String get greeting_evening => 'Good evening';

  @override
  String get greeting_night => 'Good night';

  @override
  String get trending_title => 'Trending on Aux';

  @override
  String get browse_genre_title => 'Browse by Genre';

  @override
  String get empty_liked =>
      'Nothing here yet. Hit the heart on anything you want to find again.';

  @override
  String get empty_search =>
      'No matches. Try an artist, mood, or genre instead.';

  @override
  String get empty_downloaded =>
      'Nothing downloaded yet. Tap the download icon on any track.';

  @override
  String get error_source_unavailable =>
      'Some tracks are temporarily unavailable. Everything else is playing normally.';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_dark_mode => 'Dark mode';

  @override
  String get settings_reduce_motion => 'Reduce motion';

  @override
  String get settings_reduce_motion_desc =>
      'Disables the Now Playing pulse ring and parallax effects';

  @override
  String get settings_sources_title => 'Music Sources';

  @override
  String get settings_about_title => 'About';

  @override
  String get settings_support_title => 'Where does support go?';

  @override
  String get settings_support_desc =>
      'All costs are covered by the development team. Aux is and will remain free.';

  @override
  String get library_title => 'Your Library';

  @override
  String get library_filter_playlists => 'Playlists';

  @override
  String get library_filter_artists => 'Artists';

  @override
  String get library_filter_albums => 'Albums';

  @override
  String get library_filter_podcasts => 'Podcasts';

  @override
  String get library_filter_downloaded => 'Downloaded';

  @override
  String get now_playing_license_label => 'License';

  @override
  String get search_hint => 'Artists, tracks, moods, genres…';

  @override
  String get social_title => 'Pass the Aux';

  @override
  String get social_empty => 'Start a group session and share the code.';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_search => 'Search';

  @override
  String get nav_library => 'Library';

  @override
  String get nav_social => 'Pass the Aux';

  @override
  String get mini_player_nothing_playing => 'Nothing playing';

  @override
  String get mini_player_tagline => 'Plug in. Play everything.';
}
