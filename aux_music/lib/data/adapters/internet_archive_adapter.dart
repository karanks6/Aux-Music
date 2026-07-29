import 'dart:async';
import 'package:dio/dio.dart';
import '../models/track.dart';
import '../models/artist.dart';
import '../models/license_type.dart';
import 'music_source_adapter.dart';

/// Internet Archive adapter.
///
/// Covers:
/// - Audio recordings (mediatype:audio)
/// - Live concerts (collection:etree)
/// - LibriVox audiobooks (collection:librivoxaudio)
/// - Open podcasts (collection:opensource_audio)
///
/// All tracks have a licenseurl from the Archive metadata.
/// Tracks without a parseable license are silently dropped.
///
/// Rate limit: ~3 req/sec (courtesy limit — no official cap but be polite).
class InternetArchiveAdapter implements MusicSourceAdapter {
  InternetArchiveAdapter({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const String _baseUrl = 'https://archive.org';
  static const String _searchUrl = '$_baseUrl/advancedsearch.php';
  static const Duration _timeout = Duration(seconds: 10);
  static const int _rateLimitMs = 350; // ~3 req/sec

  DateTime _lastRequestTime = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  String get sourceId => 'internet_archive';

  @override
  String get displayName => 'Internet Archive';

  @override
  bool get isEnabled => true;

  @override
  Future<void> initialize() async {
    // No initialization needed for IA — it's a simple REST API
  }

  @override
  Future<void> healthCheck() async {
    try {
      await _rateLimitedGet(
        _searchUrl,
        queryParameters: {
          'q': 'mediatype:audio',
          'fl[]': 'identifier',
          'rows': 1,
          'output': 'json',
        },
      );
    } catch (e) {
      throw SourceHealthException(sourceId, e.toString());
    }
  }

  @override
  Future<List<Track>> searchTracks(
    String query, {
    int limit = 20,
    String? genre,
    String? language,
    bool isPodcast = false,
  }) async {
    // Build IA search query
    var q = '($query) AND mediatype:audio';
    if (genre != null) q += ' AND subject:$genre';

    final items = await _searchItems(q, limit: limit);
    return _itemsToTracks(items);
  }

  @override
  Future<List<Track>> trending({
    String? genre,
    String? language,
    int limit = 20,
    bool isPodcast = false,
  }) async {
    // IA doesn't have "trending" — use recently added public-domain audio
    var q = 'mediatype:audio AND licenseurl:*';
    if (genre != null) q += ' AND subject:$genre';

    final items = await _searchItems(
      q,
      limit: limit,
      sort: 'publicdate desc',
    );
    return _itemsToTracks(items);
  }

  @override
  Future<String> resolveStreamUrl(String trackId) async {
    // trackId format: 'internet_archive:{identifier}:{filename}'
    final parts = trackId.replaceFirst('internet_archive:', '').split(':');
    if (parts.length < 2) {
      throw Exception('[IA] Invalid track ID format: $trackId');
    }
    final identifier = parts[0];
    final filename = parts.sublist(1).join(':');

    // If filename is '__auto__', we need to look up the best audio file
    // from the IA metadata API before we can build the stream URL.
    if (filename == '__auto__') {
      return _resolveAutoUrl(identifier);
    }

    return '$_baseUrl/download/$identifier/$filename';
  }

  /// Fetches IA metadata for [identifier] and returns the direct download
  /// URL for the best available audio file (MP3 preferred, then OGG/FLAC).
  Future<String> _resolveAutoUrl(String identifier) async {
    try {
      final response = await _rateLimitedGet('$_baseUrl/metadata/$identifier');
      final files = response['files'] as List? ?? [];
      
      // Priority order: mp3 > ogg > opus > flac > wav
      const preferredExts = ['.mp3', '.ogg', '.opus', '.flac', '.wav'];
      
      for (final ext in preferredExts) {
        for (final file in files.whereType<Map<String, dynamic>>()) {
          final name = file['name']?.toString() ?? '';
          if (name.toLowerCase().endsWith(ext)) {
            // URL-encode the filename to handle spaces and special chars
            final encodedName = Uri.encodeComponent(name);
            return '$_baseUrl/download/$identifier/$encodedName';
          }
        }
      }
      
      throw Exception('[IA] No playable audio file found in item: $identifier');
    } catch (e) {
      throw Exception('[IA] Failed to resolve auto URL for $identifier: $e');
    }
  }

  @override
  Future<List<Artist>> searchArtists(String query, {int limit = 10}) async {
    // IA doesn't have a separate artists endpoint — search by creator
    final items = await _searchItems(
      '($query) AND mediatype:audio',
      limit: limit,
    );
    final artists = <String, Artist>{};
    for (final item in items) {
      final creator = item['creator']?.toString() ?? '';
      if (creator.isNotEmpty && !artists.containsKey(creator)) {
        artists[creator] = Artist(
          id: 'ia_artist:$creator',
          name: creator,
          sourceId: sourceId,
        );
      }
    }
    return artists.values.take(limit).toList();
  }

  @override
  Future<List<Track>> getArtistTracks(String artistId, {int limit = 20}) async {
    final creator = artistId.replaceFirst('ia_artist:', '');
    final items = await _searchItems(
      'creator:($creator) AND mediatype:audio',
      limit: limit,
    );
    return _itemsToTracks(items);
  }

  @override
  Future<List<Track>> getAlbumTracks(String albumId) async {
    final identifier = albumId.replaceFirst('ia_album:', '');
    return _getItemFiles(identifier);
  }

  // ── Private helpers ────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _searchItems(
    String query, {
    int limit = 20,
    String sort = 'downloads desc',
  }) async {
    try {
      final response = await _rateLimitedGet(
        _searchUrl,
        queryParameters: {
          'q': query,
          'fl[]': [
            'identifier',
            'title',
            'creator',
            'licenseurl',
            'subject',
            'description',
            'avg_rating',
            'downloads',
            'publicdate',
          ],
          'sort[]': sort,
          'rows': limit,
          'output': 'json',
        },
      );

      final docs = response['response']?['docs'];
      if (docs is List) {
        return docs.cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Track>> _getItemFiles(String identifier) async {
    try {
      final response = await _rateLimitedGet(
        '$_baseUrl/metadata/$identifier',
      );
      final files = response['files'] as List? ?? [];
      final metadata = response['metadata'] as Map<String, dynamic>? ?? {};
      final licenseUrl = metadata['licenseurl']?.toString();
      final licenseType = LicenseType.fromUrl(licenseUrl);
      if (licenseType == LicenseType.unknown) return [];

      final creator = metadata['creator']?.toString() ?? 'Unknown Artist';
      final albumTitle = metadata['title']?.toString() ?? identifier;

      return files
          .whereType<Map<String, dynamic>>()
          .where((f) => _isAudioFile(f['name']?.toString() ?? ''))
          .map((f) {
            final filename = f['name']?.toString() ?? '';
            final title = _trackTitleFromFilename(filename);
            final durationSec = double.tryParse(f['length']?.toString() ?? '0')?.toInt() ?? 0;
            return Track(
              id: 'internet_archive:$identifier:$filename',
              title: title,
              artistName: creator,
              albumName: albumTitle,
              sourceId: sourceId,
              licenseType: licenseType,
              attributionString: '$creator via Internet Archive · ${licenseType.displayLabel}',
              sourceUrl: '$_baseUrl/details/$identifier',
              durationMs: durationSec * 1000,
              offlineAllowed: licenseType.offlineAllowed,
            );
          })
          .where((t) => t.isPlayable)
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<Track> _itemsToTracks(List<Map<String, dynamic>> items) {
    final tracks = <Track>[];
    for (final item in items) {
      final identifier = item['identifier']?.toString() ?? '';
      if (identifier.isEmpty) continue;

      final licenseUrl = item['licenseurl']?.toString();
      final licenseType = LicenseType.fromUrl(licenseUrl);
      // Drop tracks without a known license
      if (licenseType == LicenseType.unknown) continue;

      final creator = item['creator']?.toString() ?? 'Unknown Artist';
      final title = item['title']?.toString() ?? identifier;

      // For search results we create a "parent" track pointing to the identifier
      // Stream URL resolution will select the best audio file from the item
      final track = Track(
        id: 'internet_archive:$identifier:__auto__',
        title: title,
        artistName: creator,
        sourceId: sourceId,
        licenseType: licenseType,
        attributionString: '$creator via Internet Archive · ${licenseType.displayLabel}',
        sourceUrl: '$_baseUrl/details/$identifier',
        offlineAllowed: licenseType.offlineAllowed,
      );

      if (track.isPlayable) tracks.add(track);
    }
    return tracks;
  }

  Future<Map<String, dynamic>> _rateLimitedGet(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    // Enforce ~3 req/sec courtesy limit
    final now = DateTime.now();
    final sinceLastMs = now.difference(_lastRequestTime).inMilliseconds;
    if (sinceLastMs < _rateLimitMs) {
      await Future.delayed(Duration(milliseconds: _rateLimitMs - sinceLastMs));
    }
    _lastRequestTime = DateTime.now();

    final response = await _dio.get(
      url,
      queryParameters: queryParameters,
      options: Options(
        headers: {
          'User-Agent': 'AuxMusic/1.0 (https://auxmusic.app)',
          'Accept': 'application/json',
        },
        receiveTimeout: _timeout,
        sendTimeout: _timeout,
      ),
    );

    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {};
  }

  bool _isAudioFile(String name) {
    final ext = name.toLowerCase();
    return ext.endsWith('.mp3') ||
        ext.endsWith('.flac') ||
        ext.endsWith('.ogg') ||
        ext.endsWith('.opus') ||
        ext.endsWith('.m4a') ||
        ext.endsWith('.wav');
  }

  String _trackTitleFromFilename(String filename) {
    // Remove extension and clean up
    var name = filename;
    final dotIdx = name.lastIndexOf('.');
    if (dotIdx > 0) name = name.substring(0, dotIdx);
    // Replace underscores/dashes with spaces, title-case
    name = name.replaceAll(RegExp(r'[_-]'), ' ').trim();
    if (name.isEmpty) return filename;
    return name;
  }
}
