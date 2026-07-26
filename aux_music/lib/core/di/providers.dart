import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/adapters/adapter_aggregator.dart';
import '../../data/adapters/music_source_adapter.dart';
import '../../data/models/track.dart';

// ── Adapter Aggregator ─────────────────────────────────────────────

/// The single, shared adapter aggregator instance.
/// Initialized once at app startup.
final aggregatorProvider = Provider<MusicAdapterAggregator>((ref) {
  final aggregator = MusicAdapterAggregator();
  ref.onDispose(aggregator.dispose);
  return aggregator;
});

/// Initialization future — await this in main() before runApp
/// to ensure adapters are ready (node discovery, etc.)
final aggregatorInitProvider = FutureProvider<void>((ref) async {
  final aggregator = ref.read(aggregatorProvider);
  await aggregator.initialize();
});

// ── Trending Tracks ────────────────────────────────────────────────

final trendingTracksProvider = FutureProvider.family<List<Track>, String?>(
  (ref, genre) async {
    final aggregator = ref.read(aggregatorProvider);
    return aggregator.trending(genre: genre, limitPerSource: 25);
  },
);

// ── Search ─────────────────────────────────────────────────────────

class SearchQuery {
  const SearchQuery({
    required this.query,
    this.genre,
    this.language,
  });
  final String query;
  final String? genre;
  final String? language;

  @override
  bool operator ==(Object other) =>
      other is SearchQuery &&
      other.query == query &&
      other.genre == genre &&
      other.language == language;

  @override
  int get hashCode => Object.hash(query, genre, language);
}

final searchTracksProvider = FutureProvider.family<List<Track>, SearchQuery>(
  (ref, sq) async {
    if (sq.query.trim().isEmpty) return [];
    final aggregator = ref.read(aggregatorProvider);
    return aggregator.searchTracks(
      sq.query,
      genre: sq.genre,
      language: sq.language,
      limitPerSource: 20,
    );
  },
);

// ── Artist and Album Tracks ────────────────────────────────────────

final artistTracksProvider = FutureProvider.family<List<Track>, String>((ref, artistId) async {
  final aggregator = ref.read(aggregatorProvider);
  return aggregator.getArtistTracks(artistId);
});

final albumTracksProvider = FutureProvider.family<List<Track>, String>((ref, albumId) async {
  final aggregator = ref.read(aggregatorProvider);
  return aggregator.getAlbumTracks(albumId);
});

// ── Theme ──────────────────────────────────────────────────────────

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);
final reduceMotionProvider = StateProvider<bool>((ref) => false);
final offlineModeProvider = StateProvider<bool>((ref) => false);

// ── Reduce Motion ─────────────────────────────────────────────────

/// Respects both the user's system setting and the in-app toggle.
/// When true: pulse ring, parallax, and stagger animations are disabled.

// ── Source Health ─────────────────────────────────────────────────

final sourceHealthProvider = Provider<List<SourceHealthStatus>>((ref) {
  final aggregator = ref.read(aggregatorProvider);
  return aggregator.healthStatuses;
});
