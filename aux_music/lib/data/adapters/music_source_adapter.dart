import '../models/track.dart';
import '../models/artist.dart';

/// The single interface every music source adapter must implement.
///
/// This is explicitly load-bearing — it's what allows any source to be
/// swapped, disabled, or replaced overnight without touching UI code.
///
/// CRITICAL CONTRACT:
/// Every [Track] returned by any method MUST have:
/// - [Track.licenseType] != [LicenseType.unknown]
/// - [Track.attributionString] non-empty
/// - [Track.sourceId] matching [sourceId]
///
/// Any track that cannot satisfy these requirements must be silently
/// dropped by the adapter before returning — never returned to the UI
/// with [LicenseType.unknown].
abstract interface class MusicSourceAdapter {
  /// Unique identifier for this source (e.g., 'audius', 'internet_archive')
  String get sourceId;

  /// Human-readable source name for the Settings source-status panel
  String get displayName;

  /// Whether this adapter is enabled. Feature-flagged adapters return false here.
  bool get isEnabled;

  /// Search for tracks matching [query].
  /// Returns at most [limit] results. Adapters should NOT block on slow
  /// network — implement timeouts internally and return partial results.
  Future<List<Track>> searchTracks(
    String query, {
    int limit = 20,
    String? genre,
    String? language,
  });

  /// Fetch currently trending tracks.
  Future<List<Track>> trending({
    String? genre,
    String? language,
    int limit = 20,
  });

  /// Resolve the actual playable stream URL for a track.
  /// Called lazily just before playback begins — never eagerly.
  /// Must return a direct, playable URL (no additional redirects expected
  /// by the caller, though just_audio handles HTTP redirects natively).
  Future<String> resolveStreamUrl(String trackId);

  /// Search for artists matching [query].
  Future<List<Artist>> searchArtists(String query, {int limit = 10});

  /// Get an artist's top tracks.
  Future<List<Track>> getArtistTracks(String artistId, {int limit = 20});

  /// Get tracks in an album.
  Future<List<Track>> getAlbumTracks(String albumId);

  /// Lightweight health probe. Throws [SourceHealthException] if degraded.
  /// Should complete within 3 seconds.
  Future<void> healthCheck();

  /// Called once at startup to initialize the adapter (e.g., discover
  /// Audius nodes, validate API keys). Must not throw — log and degrade gracefully.
  Future<void> initialize();
}

/// Thrown by [MusicSourceAdapter.healthCheck] when the source is degraded.
class SourceHealthException implements Exception {
  const SourceHealthException(this.sourceId, this.reason);
  final String sourceId;
  final String reason;

  @override
  String toString() => 'SourceHealthException($sourceId): $reason';
}

/// Immutable health status snapshot for a single source adapter.
class SourceHealthStatus {
  const SourceHealthStatus({
    required this.sourceId,
    required this.displayName,
    required this.isHealthy,
    required this.checkedAt,
    this.errorMessage,
    this.latencyMs,
  });

  final String sourceId;
  final String displayName;
  final bool isHealthy;
  final DateTime checkedAt;
  final String? errorMessage;
  final int? latencyMs;

  @override
  String toString() =>
      'SourceHealthStatus($sourceId, healthy=$isHealthy, latency=${latencyMs}ms)';
}
