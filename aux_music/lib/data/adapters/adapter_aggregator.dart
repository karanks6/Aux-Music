import 'dart:async';
import 'package:dio/dio.dart';
import '../../core/config/env.dart';
import '../models/track.dart';
import '../models/artist.dart';
import 'music_source_adapter.dart';
import 'audius_adapter.dart';
import 'internet_archive_adapter.dart';
import 'jiosaavn_adapter.dart';
import 'youtube_music_adapter.dart';

/// Aggregates all source adapters, fans out searches in parallel,
/// deduplicates results, and skips degraded sources.
///
/// This is the single entry point for all music queries from the app.
/// UI code never calls individual adapters directly.
class MusicAdapterAggregator {
  MusicAdapterAggregator() {
    _adapters = [
      YouTubeMusicAdapter(),    // Primary — Global fallback (YouTube Music)
      JioSaavnAdapter(),        // Secondary — Bollywood/Indian 
    ];
  }

  late final List<MusicSourceAdapter> _adapters;
  final Set<String> _degradedSources = {};
  Timer? _healthTimer;

  // ── Lifecycle ──────────────────────────────────────────────────────

  /// Initialize all enabled adapters and start the health monitor.
  Future<void> initialize() async {
    await Future.wait(
      _enabledAdapters.map((a) => a.initialize().catchError((_) {})),
    );
    _startHealthMonitor();
  }

  void dispose() {
    _healthTimer?.cancel();
  }

  // ── Query methods ─────────────────────────────────────────────────

  /// Fan out [searchTracks] to all healthy adapters in parallel.
  /// Results are deduplicated by fuzzy title+artist match.
  Future<List<Track>> searchTracks(
    String query, {
    int limitPerSource = 20,
    String? genre,
    String? language,
  }) async {
    final results = await _fanOut(
      (adapter) => adapter.searchTracks(
        query,
        limit: limitPerSource,
        genre: genre,
        language: language,
      ),
    );
    return _deduplicateTracks(results);
  }

  /// Fetch trending tracks directly from adapters
  Future<List<Track>> trending({
    String? genre,
    String? language,
    int limitPerSource = 20,
  }) async {
    return _fanOut(
      (adapter) => adapter.trending(
        genre: genre,
        language: language,
        limit: limitPerSource,
      ),
    );
  }  /// Resolve stream URL — delegated to the correct adapter by sourceId prefix.
  Future<String> resolveStreamUrl(String trackId) async {
    final adapter = _adapterForTrackId(trackId);
    if (adapter == null) throw Exception('No adapter found for track: $trackId');
    return adapter.resolveStreamUrl(trackId);
  }

  Future<List<Artist>> searchArtists(String query, {int limit = 10}) async {
    final results = await _fanOut(
      (adapter) => adapter.searchArtists(query, limit: limit),
    );
    return results;
  }

  Future<List<Track>> getArtistTracks(String artistId, {int limit = 20}) async {
    final adapter = _adapterForTrackId(artistId);
    if (adapter == null) return [];
    return adapter.getArtistTracks(artistId, limit: limit);
  }

  Future<List<Track>> getAlbumTracks(String albumId) async {
    final adapter = _adapterForTrackId(albumId);
    if (adapter == null) return [];
    return adapter.getAlbumTracks(albumId);
  }

  // ── Health status ─────────────────────────────────────────────────

  List<SourceHealthStatus> get healthStatuses => _adapters.map((a) {
        final isDegraded = _degradedSources.contains(a.sourceId);
        return SourceHealthStatus(
          sourceId: a.sourceId,
          displayName: a.displayName,
          isHealthy: !isDegraded && a.isEnabled,
          checkedAt: DateTime.now(),
          errorMessage: isDegraded ? 'Source is temporarily unavailable' : null,
        );
      }).toList();

  // ── Internal ───────────────────────────────────────────────────────

  List<MusicSourceAdapter> get _enabledAdapters =>
      _adapters.where((a) => a.isEnabled).toList();

  List<MusicSourceAdapter> get _healthyAdapters => _enabledAdapters
      .where((a) => !_degradedSources.contains(a.sourceId))
      .toList();

  Future<List<T>> _fanOut<T>(
    Future<List<T>> Function(MusicSourceAdapter adapter) query,
  ) async {
    if (_healthyAdapters.isEmpty) return [];

    final futures = _healthyAdapters.map((adapter) async {
      try {
        return await query(adapter).timeout(const Duration(seconds: 10));
      } catch (e) {
        // ignore: avoid_print
        print('[Aggregator] Adapter ${adapter.sourceId} failed: $e');
        return <T>[];
      }
    });

    final results = await Future.wait(futures);
    // Flatten — Audius (index 0) leads, others follow
    return results.expand((r) => r).toList();
  }

  MusicSourceAdapter? _adapterForTrackId(String trackId) {
    for (final adapter in _adapters) {
      if (trackId.startsWith('${adapter.sourceId}:')) return adapter;
    }
    return null;
  }

  /// Deduplicate tracks by fuzzy title+artist match.
  /// Prefers tracks from Audius (comes first in the list).
  List<Track> _deduplicateTracks(List<Track> tracks) {
    final seen = <String>[];
    final result = <Track>[];

    for (final track in tracks) {
      final key = _normalizeKey('${track.title} ${track.artistName}');
      // Check if we've seen a "similar" key
      final isDuplicate = seen.any((k) => _isFuzzyMatch(k, key));
      if (!isDuplicate) {
        seen.add(key);
        result.add(track);
      }
    }
    return result;
  }

  String _normalizeKey(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  bool _isFuzzyMatch(String a, String b) {
    if (a == b) return true;
    if (a.isEmpty || b.isEmpty) return false;
    // Simple Jaccard-like check on word overlap
    final wordsA = a.split(' ').toSet();
    final wordsB = b.split(' ').toSet();
    final intersection = wordsA.intersection(wordsB).length;
    final union = wordsA.union(wordsB).length;
    if (union == 0) return false;
    return intersection / union > 0.8; // 80% word overlap = duplicate
  }

  // ── Health Monitor ─────────────────────────────────────────────────

  void _startHealthMonitor() {
    _healthTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      for (final adapter in _enabledAdapters) {
        try {
          await adapter.healthCheck().timeout(const Duration(seconds: 3));
          _degradedSources.remove(adapter.sourceId);
        } catch (e) {
          _degradedSources.add(adapter.sourceId);
          // ignore: avoid_print
          print('[HealthMonitor] ${adapter.sourceId} degraded: $e');
        }
      }
    });
  }
}
