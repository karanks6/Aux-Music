import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/playlist.dart' as models;
import '../../data/models/track.dart';
import '../local/database.dart' hide Playlist;
import '../../data/models/license_type.dart';

class LibraryRepository {
  final AuxDatabase _db;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  LibraryRepository(this._db, this._auth, this._firestore);

  // ── Likes ────────────────────────────────────────────────────────
  
  Stream<List<Track>> watchLikedTracks() {
    return (_db.select(_db.likedTracks)
          ..orderBy([(t) => OrderingTerm(expression: t.likedAt, mode: OrderingMode.desc)]))
        .watch()
        .map((rows) => rows.map(_mapLikedTrack).toList());
  }

  Future<void> toggleLikeTrack(Track track) async {
    final existing = await (_db.select(_db.likedTracks)..where((t) => t.id.equals(track.id))).getSingleOrNull();
    final user = _auth.currentUser;
    
    if (existing != null) {
      await (_db.delete(_db.likedTracks)..where((t) => t.id.equals(track.id))).go();
      
      // Sync to cloud
      if (user != null) {
        _firestore.collection('users').doc(user.uid).collection('liked_tracks').doc(track.id).delete().catchError((_) {});
      }
    } else {
      final likedAt = DateTime.now();
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
              likedAt: likedAt,
            ),
          );
          
      // Sync to cloud
      if (user != null) {
        final trackJson = track.toJson();
        trackJson['likedAt'] = likedAt.toIso8601String();
        _firestore.collection('users').doc(user.uid).collection('liked_tracks').doc(track.id).set(trackJson).catchError((_) {});
      }
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
    final now = DateTime.now();
    final id = await _db.into(_db.playlists).insert(
          PlaylistsCompanion.insert(
            name: name,
            description: Value(description),
            updatedAt: Value(now),
          ),
        );
        
    final user = _auth.currentUser;
    if (user != null) {
      _firestore.collection('users').doc(user.uid).collection('playlists').doc(id.toString()).set({
        'name': name,
        'description': description,
        'updatedAt': now.toIso8601String(),
      }).catchError((_) {});
    }
    return id;
  }

  Future<void> renamePlaylist(int playlistId, String newName) async {
    final now = DateTime.now();
    await (_db.update(_db.playlists)..where((p) => p.id.equals(playlistId))).write(
      PlaylistsCompanion(
        name: Value(newName),
        updatedAt: Value(now),
      ),
    );
    
    final user = _auth.currentUser;
    if (user != null) {
      _firestore.collection('users').doc(user.uid).collection('playlists').doc(playlistId.toString()).update({
        'name': newName,
        'updatedAt': now.toIso8601String(),
      }).catchError((_) {});
    }
  }

  Future<void> deletePlaylist(int playlistId) async {
    await (_db.delete(_db.playlists)..where((p) => p.id.equals(playlistId))).go();
    
    final user = _auth.currentUser;
    if (user != null) {
      _firestore.collection('users').doc(user.uid).collection('playlists').doc(playlistId.toString()).delete().catchError((_) {});
    }
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
    
    final sortOrder = currentMax + 1;
    final now = DateTime.now();

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
            sortOrder: sortOrder,
            addedAt: now,
          ),
        );

    // Update playlist updatedAt
    await (_db.update(_db.playlists)..where((p) => p.id.equals(playlistId))).write(
      PlaylistsCompanion(updatedAt: Value(now)),
    );
    
    final user = _auth.currentUser;
    if (user != null) {
      final docId = playlistId.toString();
      _firestore.collection('users').doc(user.uid).collection('playlists').doc(docId).update({
        'updatedAt': now.toIso8601String(),
      }).catchError((_) {});
      
      final trackData = track.toJson();
      trackData['sortOrder'] = sortOrder;
      
      _firestore.collection('users').doc(user.uid)
        .collection('playlists').doc(docId)
        .collection('tracks').doc(track.id)
        .set(trackData).catchError((_) {});
    }
  }
  
  Future<void> removeTrackFromPlaylist(int playlistId, String trackId) async {
    await (_db.delete(_db.playlistTracks)
          ..where((pt) => pt.playlistId.equals(playlistId) & pt.trackId.equals(trackId)))
        .go();
        
    final user = _auth.currentUser;
    if (user != null) {
      final now = DateTime.now();
      final docId = playlistId.toString();
      
      _firestore.collection('users').doc(user.uid).collection('playlists').doc(docId).update({
        'updatedAt': now.toIso8601String(),
      }).catchError((_) {});
      
      _firestore.collection('users').doc(user.uid)
        .collection('playlists').doc(docId)
        .collection('tracks').doc(trackId)
        .delete().catchError((_) {});
    }
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
    
    final user = _auth.currentUser;
    final batch = user != null ? _firestore.batch() : null;
    final docId = playlistId.toString();
    
    await _db.transaction(() async {
      for (var i = 0; i < tracks.length; i++) {
        await (_db.update(_db.playlistTracks)
              ..where((pt) => pt.playlistId.equals(playlistId) & pt.trackId.equals(tracks[i].trackId)))
            .write(PlaylistTracksCompanion(sortOrder: Value(i + 1)));
            
        if (batch != null && user != null) {
          final ref = _firestore.collection('users').doc(user.uid).collection('playlists').doc(docId).collection('tracks').doc(tracks[i].trackId);
          batch.update(ref, {'sortOrder': i + 1});
        }
      }
    });
    
    if (batch != null) {
      batch.commit().catchError((_) {});
    }
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
  
  // ── Sync Logic ────────────────────────────────────────────────────
  
  Future<void> syncUserLibrary(String uid) async {
    // 1. Sync Liked Tracks
    try {
      final likesSnapshot = await _firestore.collection('users').doc(uid).collection('liked_tracks').get();
      
      // Upload local ones not in cloud
      final localLikes = await _db.select(_db.likedTracks).get();
      final localLikeIds = localLikes.map((t) => t.id).toSet();
      final cloudLikeIds = likesSnapshot.docs.map((d) => d.id).toSet();
      
      final batch = _firestore.batch();
      for (final local in localLikes) {
        if (!cloudLikeIds.contains(local.id)) {
          final track = _mapLikedTrack(local);
          final json = track.toJson();
          json['likedAt'] = local.likedAt.toIso8601String();
          batch.set(_firestore.collection('users').doc(uid).collection('liked_tracks').doc(local.id), json);
        }
      }
      await batch.commit();

      // Download cloud ones to local
      for (final doc in likesSnapshot.docs) {
        if (!localLikeIds.contains(doc.id)) {
          final data = doc.data();
          final track = Track.fromJson(data);
          final likedAtStr = data['likedAt'] as String?;
          final likedAt = likedAtStr != null ? DateTime.parse(likedAtStr) : DateTime.now();
          
          await _db.into(_db.likedTracks).insertOnConflictUpdate(
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
              likedAt: likedAt,
            ),
          );
        }
      }
    } catch (e) {
      print('Error syncing liked tracks: $e');
    }

    // 2. Sync Playlists
    try {
      final playlistsSnapshot = await _firestore.collection('users').doc(uid).collection('playlists').get();
      
      // Get local playlists
      final localPlaylists = await _db.select(_db.playlists).get();
      final localPlaylistNames = {for (var p in localPlaylists) p.name: p.id};
      
      // We will match playlists by Name because IDs are autoincrement locally
      
      for (final doc in playlistsSnapshot.docs) {
        final data = doc.data();
        final name = data['name'] as String;
        final desc = data['description'] as String? ?? '';
        final updatedAtStr = data['updatedAt'] as String?;
        final updatedAt = updatedAtStr != null ? DateTime.parse(updatedAtStr) : DateTime.now();
        
        int localId;
        if (localPlaylistNames.containsKey(name)) {
          localId = localPlaylistNames[name]!;
        } else {
          localId = await _db.into(_db.playlists).insert(
            PlaylistsCompanion.insert(
              name: name,
              description: Value(desc),
              updatedAt: Value(updatedAt),
            ),
          );
        }
        
        // Sync Tracks for this playlist
        final tracksSnapshot = await doc.reference.collection('tracks').get();
        final cloudTrackIds = tracksSnapshot.docs.map((d) => d.id).toSet();
        
        // Upload local tracks not in cloud for this playlist
        final localTracks = await getPlaylistTracks(localId);
        final localTrackIds = localTracks.map((t) => t.id).toSet();
        
        final trackBatch = _firestore.batch();
        for (final local in localTracks) {
          if (!cloudTrackIds.contains(local.id)) {
            final json = local.toJson();
            trackBatch.set(doc.reference.collection('tracks').doc(local.id), json);
          }
        }
        await trackBatch.commit();
        
        // Download cloud tracks to local
        for (final trackDoc in tracksSnapshot.docs) {
          if (!localTrackIds.contains(trackDoc.id)) {
            final trackData = trackDoc.data();
            final track = Track.fromJson(trackData);
            final sortOrder = trackData['sortOrder'] as int? ?? 0;
            
            await _db.into(_db.playlistTracks).insertOnConflictUpdate(
              PlaylistTrack(
                playlistId: localId,
                trackId: track.id,
                title: track.title,
                artistName: track.artistName,
                artworkUrl: track.artworkUrl,
                sourceId: track.sourceId,
                licenseType: track.licenseType.name,
                attributionString: track.attributionString,
                trackJson: jsonEncode(track.toJson()),
                sortOrder: sortOrder,
                addedAt: DateTime.now(),
              ),
            );
          }
        }
      }
      
      // Upload local playlists not in cloud
      final cloudPlaylistNames = playlistsSnapshot.docs.map((d) => d.data()['name'] as String).toSet();
      for (final local in localPlaylists) {
        if (!cloudPlaylistNames.contains(local.name)) {
          final docRef = _firestore.collection('users').doc(uid).collection('playlists').doc(local.id.toString());
          await docRef.set({
            'name': local.name,
            'description': local.description,
            'updatedAt': local.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
          });
          
          final localTracks = await getPlaylistTracks(local.id);
          final pBatch = _firestore.batch();
          for (final lt in localTracks) {
             pBatch.set(docRef.collection('tracks').doc(lt.id), lt.toJson());
          }
          await pBatch.commit();
        }
      }
      
    } catch (e) {
      print('Error syncing playlists: $e');
    }
  }
  
  Future<void> clearUserData() async {
    // Clear liked tracks and playlists from local SQLite
    await _db.delete(_db.likedTracks).go();
    await _db.delete(_db.playlists).go();
    await _db.delete(_db.playlistTracks).go();
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
