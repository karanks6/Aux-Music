import 'dart:convert';
import 'package:drift/drift.dart';
import '../../data/models/playlist.dart' as models;
import '../../data/models/track.dart';
import '../local/database.dart' hide Playlist;
import '../../data/models/license_type.dart';

class LibraryRepository {
  final AuxDatabase _db;

  LibraryRepository(this._db);

  // ── Likes ────────────────────────────────────────────────────────
  
  Stream<List<Track>> watchLikedTracks() {
    return (_db.select(_db.likedTracks)
          ..orderBy([(t) => OrderingTerm(expression: t.likedAt, mode: OrderingMode.desc)]))
        .watch()
        .map((rows) => rows.map(_mapLikedTrack).toList());
  }

  Future<void> toggleLikeTrack(Track track) async {
    final existing = await (_db.select(_db.likedTracks)..where((t) => t.id.equals(track.id))).getSingleOrNull();
    if (existing != null) {
      await (_db.delete(_db.likedTracks)..where((t) => t.id.equals(track.id))).go();
    } else {
      await _db.into(_db.likedTracks).insert(
            LikedTrack(
              id: track.id,
              title: track.title,
              artistName: track.artistName,
              artistId: track.artistId,
              albumName: track.albumName,
              albumId: track.albumId,
              artworkUrl: track.artworkUrl,
              thumbnailUrl: track.thumbnailUrl,
              sourceId: track.sourceId,
              licenseType: track.licenseType.name,
              attributionString: track.attributionString,
              sourceUrl: track.sourceUrl,
              language: track.language,
              durationMs: track.durationMs,
              playCount: track.playCount,
              offlineAllowed: track.offlineAllowed,
              likedAt: DateTime.now(),
            ),
          );
    }
  }

  Future<bool> isTrackLiked(String trackId) async {
    final count = countAll();
    final query = _db.selectOnly(_db.likedTracks)
      ..addColumns([count])
      ..where(_db.likedTracks.id.equals(trackId));
    final result = await query.getSingle();
    return result.read(count)! > 0;
  }

  // ── Downloads ────────────────────────────────────────────────────
  
  Stream<List<DownloadedFile>> watchDownloadedFiles() {
    return _db.select(_db.downloadedFiles).watch();
  }

  Future<DownloadedFile?> getDownload(String trackId) async {
    return (_db.select(_db.downloadedFiles)..where((d) => d.trackId.equals(trackId))).getSingleOrNull();
  }

  Future<void> markDownloaded(Track track, String localPath, int sizeBytes) async {
    await _db.into(_db.downloadedFiles).insertOnConflictUpdate(
          DownloadedFile(
            trackId: track.id,
            localPath: localPath,
            sizeBytes: sizeBytes,
            downloadedAt: DateTime.now(),
            title: track.title,
            artistName: track.artistName,
            artworkUrl: track.artworkUrl,
          ),
        );
  }

  Future<void> removeDownload(String trackId) async {
    await (_db.delete(_db.downloadedFiles)..where((d) => d.trackId.equals(trackId))).go();
  }

  // ── Playlists ────────────────────────────────────────────────────
  
  Stream<List<models.Playlist>> watchPlaylists() {
    return (_db.select(_db.playlists)
          ..orderBy([(p) => OrderingTerm(expression: p.updatedAt, mode: OrderingMode.desc)]))
        .watch()
        .map((playlists) => playlists.map((p) => models.Playlist(
        id: p.id.toString(),
        ownerId: 'local',
        name: p.name,
        description: p.description,
      )).toList());
  }

  Future<int> createPlaylist(String name, {String description = ''}) async {
    return _db.into(_db.playlists).insert(
          PlaylistsCompanion.insert(
            name: name,
            description: Value(description),
          ),
        );
  }

  Future<void> renamePlaylist(int playlistId, String newName) async {
    await (_db.update(_db.playlists)..where((p) => p.id.equals(playlistId))).write(
      PlaylistsCompanion(
        name: Value(newName),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deletePlaylist(int playlistId) async {
    await (_db.delete(_db.playlists)..where((p) => p.id.equals(playlistId))).go();
  }

  Stream<List<Track>> watchPlaylistTracks(int playlistId) {
    return (_db.select(_db.playlistTracks)
          ..where((pt) => pt.playlistId.equals(playlistId))
          ..orderBy([(pt) => OrderingTerm(expression: pt.sortOrder, mode: OrderingMode.asc)]))
        .watch()
        .map((rows) => rows.map((r) => Track.fromJson(jsonDecode(r.trackJson) as Map<String, dynamic>)).toList());
  }

  Future<List<Track>> getPlaylistTracks(int playlistId) async {
    final rows = await (_db.select(_db.playlistTracks)
          ..where((pt) => pt.playlistId.equals(playlistId))
          ..orderBy([(pt) => OrderingTerm(expression: pt.sortOrder, mode: OrderingMode.asc)]))
        .get();
    return rows.map((r) => Track.fromJson(jsonDecode(r.trackJson) as Map<String, dynamic>)).toList();
  }

  Future<void> addTrackToPlaylist(int playlistId, Track track) async {
    // Get max sort order
    final maxSort = _db.playlistTracks.sortOrder.max();
    final query = _db.selectOnly(_db.playlistTracks)
      ..addColumns([maxSort])
      ..where(_db.playlistTracks.playlistId.equals(playlistId));
    final result = await query.getSingle();
    final currentMax = result.read(maxSort) ?? 0;

    await _db.into(_db.playlistTracks).insert(
          PlaylistTrack(
            playlistId: playlistId,
            trackId: track.id,
            title: track.title,
            artistName: track.artistName,
            artworkUrl: track.artworkUrl,
            sourceId: track.sourceId,
            licenseType: track.licenseType.name,
            attributionString: track.attributionString,
            trackJson: jsonEncode(track.toJson()),
            sortOrder: currentMax + 1,
            addedAt: DateTime.now(),
          ),
        );

    // Update playlist updatedAt
    await (_db.update(_db.playlists)..where((p) => p.id.equals(playlistId))).write(
      PlaylistsCompanion(updatedAt: Value(DateTime.now())),
    );
  }
  
  Future<void> removeTrackFromPlaylist(int playlistId, String trackId) async {
    await (_db.delete(_db.playlistTracks)
          ..where((pt) => pt.playlistId.equals(playlistId) & pt.trackId.equals(trackId)))
        .go();
  }

  Future<void> reorderPlaylistTracks(int playlistId, int oldIndex, int newIndex) async {
    final tracks = await (_db.select(_db.playlistTracks)
          ..where((pt) => pt.playlistId.equals(playlistId))
          ..orderBy([(pt) => OrderingTerm(expression: pt.sortOrder, mode: OrderingMode.asc)]))
        .get();

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final track = tracks.removeAt(oldIndex);
    tracks.insert(newIndex, track);
    
    await _db.transaction(() async {
      for (var i = 0; i < tracks.length; i++) {
        await (_db.update(_db.playlistTracks)
              ..where((pt) => pt.playlistId.equals(playlistId) & pt.trackId.equals(tracks[i].trackId)))
            .write(PlaylistTracksCompanion(sortOrder: Value(i + 1)));
      }
    });
  }

  // ── Recent Searches ──────────────────────────────────────────────

  Stream<List<String>> watchRecentSearches({int limit = 10}) {
    return (_db.select(_db.recentSearches)
          ..orderBy([(r) => OrderingTerm(expression: r.searchedAt, mode: OrderingMode.desc)])
          ..limit(limit))
        .watch()
        .map((rows) => rows.map((r) => r.query).toList());
  }

  Future<void> addRecentSearch(String query) async {
    await _db.into(_db.recentSearches).insertOnConflictUpdate(
          RecentSearchesCompanion.insert(
            query: query.trim(),
            searchedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> clearRecentSearches() async {
    await _db.delete(_db.recentSearches).go();
  }

  // ── Offline Export ────────────────────────────────────────────────

  Future<String> generateM3uExport() async {
    final downloads = await _db.select(_db.downloadedFiles).get();
    
    final buffer = StringBuffer();
    buffer.writeln('#EXTM3U');
    
    for (final download in downloads) {
      // Need metadata to make it a nice M3U
      // Try to find in liked tracks first
      String title = download.trackId;
      String artist = 'Unknown';
      
      final liked = await (_db.select(_db.likedTracks)..where((t) => t.id.equals(download.trackId))).getSingleOrNull();
      if (liked != null) {
        title = liked.title;
        artist = liked.artistName;
      } else {
        // Look in playlist tracks
        final pTrack = await (_db.select(_db.playlistTracks)..where((t) => t.trackId.equals(download.trackId))..limit(1)).getSingleOrNull();
        if (pTrack != null) {
          title = pTrack.title;
          artist = pTrack.artistName;
        }
      }
      
      buffer.writeln('#EXTINF:-1, $artist - $title');
      buffer.writeln(download.localPath);
    }
    
    return buffer.toString();
  }
  
  // ── Mappers ──────────────────────────────────────────────────────
  
  Track _mapLikedTrack(LikedTrack row) {
    return Track(
      id: row.id,
      title: row.title,
      artistName: row.artistName,
      artistId: row.artistId,
      albumName: row.albumName,
      albumId: row.albumId,
      artworkUrl: row.artworkUrl,
      thumbnailUrl: row.thumbnailUrl,
      sourceId: row.sourceId,
      licenseType: LicenseType.values.firstWhere((e) => e.name == row.licenseType, orElse: () => LicenseType.unknown),
      attributionString: row.attributionString,
      sourceUrl: row.sourceUrl,
      language: row.language,
      durationMs: row.durationMs,
      playCount: row.playCount,
      offlineAllowed: row.offlineAllowed,
    );
  }
}
