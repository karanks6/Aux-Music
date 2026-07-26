import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Aux'**
  String get appName;

  /// No description provided for @greeting_morning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greeting_morning;

  /// No description provided for @greeting_afternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greeting_afternoon;

  /// No description provided for @greeting_evening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greeting_evening;

  /// No description provided for @greeting_night.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get greeting_night;

  /// No description provided for @trending_title.
  ///
  /// In en, this message translates to:
  /// **'Trending on Aux'**
  String get trending_title;

  /// No description provided for @browse_genre_title.
  ///
  /// In en, this message translates to:
  /// **'Browse by Genre'**
  String get browse_genre_title;

  /// No description provided for @empty_liked.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet. Hit the heart on anything you want to find again.'**
  String get empty_liked;

  /// No description provided for @empty_search.
  ///
  /// In en, this message translates to:
  /// **'No matches. Try an artist, mood, or genre instead.'**
  String get empty_search;

  /// No description provided for @empty_downloaded.
  ///
  /// In en, this message translates to:
  /// **'Nothing downloaded yet. Tap the download icon on any track.'**
  String get empty_downloaded;

  /// No description provided for @error_source_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Some tracks are temporarily unavailable. Everything else is playing normally.'**
  String get error_source_unavailable;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get settings_dark_mode;

  /// No description provided for @settings_reduce_motion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get settings_reduce_motion;

  /// No description provided for @settings_reduce_motion_desc.
  ///
  /// In en, this message translates to:
  /// **'Disables the Now Playing pulse ring and parallax effects'**
  String get settings_reduce_motion_desc;

  /// No description provided for @settings_sources_title.
  ///
  /// In en, this message translates to:
  /// **'Music Sources'**
  String get settings_sources_title;

  /// No description provided for @settings_about_title.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about_title;

  /// No description provided for @settings_support_title.
  ///
  /// In en, this message translates to:
  /// **'Where does support go?'**
  String get settings_support_title;

  /// No description provided for @settings_support_desc.
  ///
  /// In en, this message translates to:
  /// **'All costs are covered by the development team. Aux is and will remain free.'**
  String get settings_support_desc;

  /// No description provided for @library_title.
  ///
  /// In en, this message translates to:
  /// **'Your Library'**
  String get library_title;

  /// No description provided for @library_filter_playlists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get library_filter_playlists;

  /// No description provided for @library_filter_artists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get library_filter_artists;

  /// No description provided for @library_filter_albums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get library_filter_albums;

  /// No description provided for @library_filter_podcasts.
  ///
  /// In en, this message translates to:
  /// **'Podcasts'**
  String get library_filter_podcasts;

  /// No description provided for @library_filter_downloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get library_filter_downloaded;

  /// No description provided for @now_playing_license_label.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get now_playing_license_label;

  /// No description provided for @search_hint.
  ///
  /// In en, this message translates to:
  /// **'Artists, tracks, moods, genres…'**
  String get search_hint;

  /// No description provided for @social_title.
  ///
  /// In en, this message translates to:
  /// **'Pass the Aux'**
  String get social_title;

  /// No description provided for @social_empty.
  ///
  /// In en, this message translates to:
  /// **'Start a group session and share the code.'**
  String get social_empty;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get nav_search;

  /// No description provided for @nav_library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get nav_library;

  /// No description provided for @nav_social.
  ///
  /// In en, this message translates to:
  /// **'Pass the Aux'**
  String get nav_social;

  /// No description provided for @mini_player_nothing_playing.
  ///
  /// In en, this message translates to:
  /// **'Nothing playing'**
  String get mini_player_nothing_playing;

  /// No description provided for @mini_player_tagline.
  ///
  /// In en, this message translates to:
  /// **'Plug in. Play everything.'**
  String get mini_player_tagline;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
