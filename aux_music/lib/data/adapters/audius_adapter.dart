import 'dart:async';
import 'package:dio/dio.dart';
import '../models/track.dart';
import '../models/artist.dart';
import '../models/license_type.dart';
import 'music_source_adapter.dart';

/// Audius adapter — primary music source.
///
/// Audius is free and open for third-party apps by design.
/// No API key required for read-only. Rate limit: ~10 req/sec.
///
/// Architecture:
/// - Discovers healthy discovery nodes at startup from the registry endpoint.
/// - Rotates to the next node on timeout or 5xx response.
/// - All tracks returned carry CC BY (Audius's default) attribution.
///   Some Audius artists use "All Rights Reserved" — we parse this and
///   skip those tracks since they cannot be played under an open license.
class AudiusAdapter implements MusicSourceAdapter {
  AudiusAdapter({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  // Known fallback nodes — updated at startup from registry
  static const List<String> _fallbackNodes = [
    'https://discoveryprovider.audius.co',
    'https://discoveryprovider2.audius.co',
    'https://discoveryprovider3.audius.co',
  ];

  static const String _registryUrl = 'https://api.audius.co';
  static const String _appName = 'AuxMusic';
  static const Duration _timeout = Duration(seconds: 8);
  static const Duration _nodeTimeout = Duration(seconds: 3);

  List<String> _nodes = List.from(_fallbackNodes);
  int _currentNodeIndex = 0;
  bool _initialized = false;

  @override
  String get sourceId => 'audius';

  @override
  String get displayName => 'Audius';

  @override
  bool get isEnabled => true;

  String get _baseUrl => _nodes[_currentNodeIndex];

  // ── Initialization ─────────────────────────────────────────────────

  @override
  Future<void> initialize() async {
    try {
      final response = await _dio.get(
        _registryUrl,
        options: Options(
          headers: _headers,
          receiveTimeout: _nodeTimeout,
          sendTimeout: _nodeTimeout,
        ),
      );
      final data = response.data;
      if (data is Map && data['data'] is List) {
        final discovered = (data['data'] as List)
            .map((e) => e.toString())
            .where((url) => url.startsWith('https://'))
            .toList();
        if (discovered.isNotEmpty) {
          _nodes = discovered;
          _currentNodeIndex = 0;
        }
      }
    } catch (e) {
      // Fall back to hardcoded nodes — logged but not rethrown
      // ignore: avoid_print
      print('[AudiusAdapter] Node discovery failed, using fallback: $e');
    }
    _initialized = true;
  }

  // ── Health Check ───────────────────────────────────────────────────

  @override
  Future<void> healthCheck() async {
    final sw = Stopwatch()..start();
    try {
      await _dio.get(
        '$_baseUrl/v1/tracks/trending?limit=1',
        options: Options(
          headers: _headers,
          receiveTimeout: _nodeTimeout,
          sendTimeout: _nodeTimeout,
        ),
      );
      sw.stop();
    } catch (e) {
      sw.stop();
      // Try rotating to the next node
      _rotateNode();
      throw SourceHealthException(sourceId, e.toString());
    }
  }

  // ── Search ─────────────────────────────────────────────────────────

  @override
  Future<List<Track>> searchTracks(
    String query, {
    int limit = 20,
    String? genre,
    String? language,
    bool isPodcast = false,
  }) async {
    if (!_initialized) await initialize();
    final params = {
      'query': query,
      'limit': limit,
      'app_name': _appName,
    };
    try {
      final response = await _getWithFallback(
        '/v1/tracks/search',
        queryParameters: params,
      );
      return _parseTracks(response);
    } catch (e) {
      return [];
    }
  }

  // ── Trending ───────────────────────────────────────────────────────

  @override
  Future<List<Track>> trending({
    String? genre,
    String? language,
    int limit = 20,
    bool isPodcast = false,
  }) async {
    if (!_initialized) await initialize();
    final params = <String, dynamic>{
      'limit': limit,
      'app_name': _appName,
    };
    if (genre != null && genre.isNotEmpty) params['genre'] = genre;

    try {
      final response = await _getWithFallback(
        '/v1/tracks/trending',
        queryParameters: params,
      );
      return _parseTracks(response);
    } catch (e) {
      return [];
    }
  }

  // ── Stream URL Resolution ──────────────────────────────────────────

  @override
  Future<String> resolveStreamUrl(String trackId, {String? title, String? artistName}) async {
    if (!_initialized) await initialize();
    // Extract the native Audius track ID (strip 'audius:' prefix if present)
    final nativeId = trackId.replaceFirst('audius:', '');
    // Audius stream endpoint returns a redirect to the CDN URL
    // just_audio handles the redirect natively — we return the initial URL
    return '$_baseUrl/v1/tracks/$nativeId/stream?app_name=$_appName';
  }

  // ── Artists ────────────────────────────────────────────────────────

  @override
  Future<List<Artist>> searchArtists(String query, {int limit = 10}) async {
    if (!_initialized) await initialize();
    try {
      final response = await _getWithFallback(
        '/v1/users/search',
        queryParameters: {
          'query': query,
          'limit': limit,
          'app_name': _appName,
        },
      );
      return _parseArtists(response);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Track>> getArtistTracks(String artistId, {int limit = 20}) async {
    if (!_initialized) await initialize();
    final nativeId = artistId.replaceFirst('audius:', '');
    try {
      final response = await _getWithFallback(
        '/v1/users/$nativeId/tracks',
        queryParameters: {'limit': limit, 'app_name': _appName},
      );
      return _parseTracks(response);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Track>> getAlbumTracks(String albumId) async {
    if (!_initialized) await initialize();
    final nativeId = albumId.replaceFirst('audius_album:', '');
    try {
      final response = await _getWithFallback(
        '/v1/playlists/$nativeId/tracks',
        queryParameters: {'app_name': _appName},
      );
      return _parseTracks(response);
    } catch (e) {
      return [];
    }
  }

  // ── Internal helpers ───────────────────────────────────────────────

  Map<String, String> get _headers => {
        'User-Agent': 'AuxMusic/1.0 (https://auxmusic.app)',
        'Accept': 'application/json',
      };

  Future<Map<String, dynamic>> _getWithFallback(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    int attempts = 0;
    while (attempts < _nodes.length) {
      try {
        final response = await _dio.get(
          '$_baseUrl$path',
          queryParameters: queryParameters,
          options: Options(
            headers: _headers,
            receiveTimeout: _timeout,
            sendTimeout: _timeout,
          ),
        );
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        }
        throw Exception('Unexpected response type');
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            (e.response?.statusCode ?? 0) >= 500) {
          _rotateNode();
          attempts++;
        } else {
          rethrow;
        }
      }
    }
    throw SourceHealthException(sourceId, 'All nodes exhausted');
  }

  void _rotateNode() {
    _currentNodeIndex = (_currentNodeIndex + 1) % _nodes.length;
    // ignore: avoid_print
    print('[AudiusAdapter] Rotated to node: ${_nodes[_currentNodeIndex]}');
  }

  List<Track> _parseTracks(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is! List) return [];

    final tracks = <Track>[];
    for (final item in data) {
      if (item is! Map<String, dynamic>) continue;
      final track = _parseTrack(item);
      if (track != null && track.isPlayable) {
        tracks.add(track);
      }
    }
    return tracks;
  }

  Track? _parseTrack(Map<String, dynamic> item) {
    try {
      final id = item['id']?.toString() ?? '';
      if (id.isEmpty) return null;

      final title = item['title']?.toString() ?? '';
      final user = item['user'] as Map<String, dynamic>? ?? {};
      final artistName = user['name']?.toString() ?? 'Unknown Artist';
      final artistId = user['id']?.toString() ?? '';

      // License: Audius tracks default to "CC BY" unless explicitly "All Rights Reserved"
      final downloadable = item['downloadable'] as bool? ?? false;
      final license = item['license']?.toString() ?? '';
      LicenseType licenseType;
      if (license.toLowerCase().contains('all rights reserved') ||
          license.toLowerCase().contains('arr')) {
        // Skip — cannot play under open license
        return null;
      } else if (license.isNotEmpty) {
        licenseType = LicenseType.fromUrl(license);
      } else {
        // Audius platform default — considered CC BY for independent artists
        licenseType = LicenseType.ccBy;
      }

      final durationSec = (item['duration'] as num?)?.toInt() ?? 0;
      final playCount = (item['play_count'] as num?)?.toInt() ?? 0;

      // Artwork
      final artwork = item['artwork'] as Map<String, dynamic>? ?? {};
      final artworkUrl = artwork['1000x1000']?.toString() ??
          artwork['480x480']?.toString();
      final thumbnailUrl = artwork['150x150']?.toString();

      // Genre / tags
      final genre = item['genre']?.toString() ?? '';
      final tags = (item['tags']?.toString() ?? '')
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final attribution = '$artistName via Audius · ${licenseType.displayLabel}';
      final sourceUrl = 'https://audius.co/tracks/$id';

      return Track(
        id: 'audius:$id',
        title: title,
        artistName: artistName,
        artistId: 'audius:$artistId',
        artworkUrl: artworkUrl,
        thumbnailUrl: thumbnailUrl,
        sourceId: sourceId,
        licenseType: licenseType,
        attributionString: attribution,
        sourceUrl: sourceUrl,
        durationMs: durationSec * 1000,
        playCount: playCount,
        offlineAllowed: downloadable || licenseType.offlineAllowed,
        genres: genre.isNotEmpty ? [genre] : [],
        tags: tags,
      );
    } catch (e) {
      return null;
    }
  }

  List<Artist> _parseArtists(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(_parseArtist)
        .whereType<Artist>()
        .toList();
  }

  Artist? _parseArtist(Map<String, dynamic> item) {
    try {
      final id = item['id']?.toString() ?? '';
      if (id.isEmpty) return null;
      final profilePicture = item['profile_picture'] as Map<String, dynamic>? ?? {};
      return Artist(
        id: 'audius:$id',
        name: item['name']?.toString() ?? 'Unknown',
        sourceId: sourceId,
        avatarUrl: profilePicture['480x480']?.toString(),
        followerCount: (item['follower_count'] as num?)?.toInt() ?? 0,
        trackCount: (item['track_count'] as num?)?.toInt() ?? 0,
        bio: item['bio']?.toString() ?? '',
        location: item['location']?.toString() ?? '',
      );
    } catch (e) {
      return null;
    }
  }
}
