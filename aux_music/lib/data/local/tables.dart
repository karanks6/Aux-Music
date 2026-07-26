import 'package:drift/drift.dart';

/// Schema for tracks that have been liked (added to the library).
class LikedTracks extends Table {
  // Track ID (e.g., 'audius:1234')
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get artistName => text()();
  TextColumn get artistId => text()();
  TextColumn get albumName => text()();
  TextColumn get albumId => text()();
  TextColumn get artworkUrl => text().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  TextColumn get sourceId => text()();
  TextColumn get licenseType => text()();
  TextColumn get attributionString => text()();
  TextColumn get sourceUrl => text()();
  TextColumn get language => text()();
  IntColumn get durationMs => integer()();
  IntColumn get playCount => integer()();
  BoolColumn get offlineAllowed => boolean()();
  
  // Timestamps
  DateTimeColumn get likedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Schema for user-created playlists.
class Playlists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get coverUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Schema for tracks within a playlist (many-to-many relationship).
class PlaylistTracks extends Table {
  IntColumn get playlistId => integer().references(Playlists, #id, onDelete: KeyAction.cascade)();
  TextColumn get trackId => text()();
  
  // Cached track data (denormalized so we don't strictly require it in LikedTracks)
  TextColumn get title => text()();
  TextColumn get artistName => text()();
  TextColumn get artworkUrl => text().nullable()();
  TextColumn get sourceId => text()();
  TextColumn get licenseType => text()();
  TextColumn get attributionString => text()();
  
  // Full JSON of the track just in case
  TextColumn get trackJson => text()();
  
  // Ordering within the playlist
  IntColumn get sortOrder => integer()();
  
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {playlistId, trackId};
}

/// Schema for downloaded tracks for offline playback.
class DownloadedFiles extends Table {
  TextColumn get trackId => text()(); // The Aux track ID
  TextColumn get localPath => text()(); // Path to the file on device
  IntColumn get sizeBytes => integer()();
  DateTimeColumn get downloadedAt => dateTime().withDefault(currentDateAndTime)();
  
  TextColumn get title => text().nullable()();
  TextColumn get artistName => text().nullable()();
  TextColumn get artworkUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {trackId};
}

/// Schema for recently searched queries.
class RecentSearches extends Table {
  TextColumn get query => text()();
  DateTimeColumn get searchedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {query};
}

/// Schema for subscribed podcasts.
class SubscribedPodcasts extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get author => text()();
  TextColumn get description => text()();
  TextColumn get artworkUrl => text().nullable()();
  TextColumn get feedUrl => text()();
  DateTimeColumn get subscribedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Schema for podcast episodes listening progress.
class PodcastEpisodesProgress extends Table {
  TextColumn get episodeId => text()();
  TextColumn get podcastId => text().references(SubscribedPodcasts, #id, onDelete: KeyAction.cascade)();
  IntColumn get progressMs => integer().withDefault(const Constant(0))();
  IntColumn get durationMs => integer()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastListenedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {episodeId};
}

