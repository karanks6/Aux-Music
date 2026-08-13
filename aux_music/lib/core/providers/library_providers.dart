import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/local/database.dart' hide Playlist;
import '../../data/repositories/library_repository.dart';
import '../../data/models/playlist.dart';
import '../../data/models/track.dart';

// ── Database & Repository ──────────────────────────────────────────

final databaseProvider = Provider<AuxDatabase>((ref) {
  final db = AuxDatabase();
  ref.onDispose(db.close);
  return db;
});

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository(
    ref.watch(databaseProvider),
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );
});

// ── Streams (Reactive UI) ──────────────────────────────────────────

final likedTracksProvider = StreamProvider<List<Track>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchLikedTracks();
});

final playlistsProvider = StreamProvider<List<Playlist>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchPlaylists();
});

final playlistTracksProvider = StreamProvider.family<List<Track>, int>((ref, playlistId) {
  return ref.watch(libraryRepositoryProvider).watchPlaylistTracks(playlistId);
});

final downloadedFilesProvider = StreamProvider<List<DownloadedFile>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchDownloadedFiles();
});

final recentSearchesProvider = StreamProvider<List<String>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchRecentSearches();
});

// ── Checks ─────────────────────────────────────────────────────────

final isTrackLikedProvider = FutureProvider.family<bool, String>((ref, trackId) async {
  // We can re-fetch this if likedTracksProvider changes
  ref.watch(likedTracksProvider);
  return ref.read(libraryRepositoryProvider).isTrackLiked(trackId);
});
