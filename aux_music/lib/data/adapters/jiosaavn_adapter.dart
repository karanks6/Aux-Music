import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/block/des_base.dart';
import 'dart:typed_data';

import '../models/track.dart';
import '../models/artist.dart';
import '../models/license_type.dart';
import 'music_source_adapter.dart';

class _DESEngine extends DesBase implements BlockCipher {
  List<int>? _workingKey;

  @override
  String get algorithmName => 'DES';

  @override
  int get blockSize => 8;

  @override
  void init(bool forEncryption, CipherParameters? params) {
    if (params is KeyParameter) {
      _workingKey = generateWorkingKey(forEncryption, params.key);
    }
  }

  @override
  int processBlock(Uint8List inp, int inpOff, Uint8List out, int outOff) {
    desFunc(_workingKey!, inp, inpOff, out, outOff);
    return 8;
  }

  @override
  Uint8List process(Uint8List data) {
    final out = Uint8List(8);
    processBlock(data, 0, out, 0);
    return out;
  }

  @override
  void reset() {}
}

class JioSaavnAdapter implements MusicSourceAdapter {
  JioSaavnAdapter({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://www.jiosaavn.com/api.php',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {
                  'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120.0.0.0 Mobile Safari/537.36',
                  'Accept': 'application/json',
                },
              ),
            );

  final Dio _dio;

  @override
  String get sourceId => 'jiosaavn';

  @override
  String get displayName => 'JioSaavn';

  @override
  bool get isEnabled => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> healthCheck() async {
    final results = await searchTracks('arijit singh', limit: 1);
    if (results.isEmpty) throw SourceHealthException(sourceId, 'No results');
  }

  // ── DES Decryption ──────────────────────────────────────────────────

  String? _decodeMediaUrl(String? encodedUrl, {bool force320 = false}) {
    if (encodedUrl == null || encodedUrl.isEmpty) return null;
    try {
      final cipher = PaddedBlockCipherImpl(
        PKCS7Padding(),
        ECBBlockCipher(_DESEngine()),
      );
      
      cipher.init(
        false, // false = decrypt
        PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
          KeyParameter(Uint8List.fromList(utf8.encode('38346591'))),
          null,
        ),
      );
      
      final encryptedBytes = base64.decode(encodedUrl);
      final decryptedBytes = cipher.process(encryptedBytes);
      
      String url = utf8.decode(decryptedBytes)
          .replaceAll('\u0000', '')
          .trim()
          .replaceAll('&amp;', '&')
          .replaceAllMapped(
            RegExp(r'https?:\/\/[^\/]*(aac\.saavncdn\.com|c\.saavncdn\.com)'),
            (m) => 'https://aac.saavncdn.com',
          );

      if (force320) {
        if (url.contains('_96.mp4')) url = url.replaceAll('_96.mp4', '_320.mp4');
        if (url.contains('_160.mp4')) url = url.replaceAll('_160.mp4', '_320.mp4');
        if (url.contains('_128.mp4')) url = url.replaceAll('_128.mp4', '_320.mp4');
      } else {
        // Upgrade 96kbps to 160kbps which is almost universally available
        if (url.contains('_96.mp4')) url = url.replaceAll('_96.mp4', '_160.mp4');
      }

      return url;
    } catch (e) {
      String url = encodedUrl
          .replaceAll('&amp;', '&')
          .replaceAllMapped(
            RegExp(r'https?:\/\/[^\/]*(aac\.saavncdn\.com|c\.saavncdn\.com)'),
            (m) => 'https://aac.saavncdn.com',
          );
      if (force320) {
        if (url.contains('_96.mp4')) url = url.replaceAll('_96.mp4', '_320.mp4');
      } else {
        if (url.contains('_96.mp4')) url = url.replaceAll('_96.mp4', '_160.mp4');
      }
      return url;
    }
  }

  Future<dynamic> _apiGet(Map<String, dynamic> params) async {
    final response = await _dio.get('', queryParameters: {
      ...params,
      '_format': 'json',
      '_marker': '0',
      'api_version': '4',
      'ctx': 'web6dot0',
    });
    // JioSaavn often returns raw strings if there's an error, handle safely
    if (response.data is String) {
      return jsonDecode(response.data as String);
    }
    return response.data;
  }

  Track? _parseTrack(Map<String, dynamic>? song) {
    if (song == null || song['id'] == null) return null;
    try {
      final moreInfo = song['more_info'] ?? <String, dynamic>{};
      final mediaUrl = _decodeMediaUrl(
        moreInfo['encrypted_media_url'] as String? ?? song['media_preview_url'] as String?,
        force320: moreInfo['320kbps'] == 'true' || moreInfo['320kbps'] == true,
      );
      if (mediaUrl == null) return null;

      final artistName = moreInfo['singers'] ??
          song['primary_artists'] ??
          song['subtitle'] ??
          'Unknown Artist';

      final artworkStr = song['image'] as String? ?? '';
      final artworkUrl = artworkStr.isNotEmpty
          ? artworkStr.replaceAll('150x150', '500x500').replaceAll('50x50', '500x500')
          : null;

      final durationStr = moreInfo['duration'] ?? song['duration'] ?? '0';
      final durationMs = (int.tryParse(durationStr.toString()) ?? 0) * 1000;
      
      final title = (song['title'] ?? song['song'] ?? '')
          .toString()
          .replaceAll('&amp;', '&')
          .replaceAll('&#039;', "'")
          .replaceAll('&quot;', '"');

      return Track(
        id: 'jiosaavn:${song['id']}',
        title: title,
        artistName: artistName.toString().replaceAll('&amp;', '&').replaceAll('&#039;', "'").replaceAll('&quot;', '"'),
        artistId: 'jiosaavn_artist:${moreInfo['artistid'] ?? ''}',
        albumName: (moreInfo['album'] ?? '').toString().replaceAll('&amp;', '&').replaceAll('&quot;', '"'),
        artworkUrl: artworkUrl,
        thumbnailUrl: artworkStr.isNotEmpty ? artworkStr.replaceAll('150x150', '150x150') : null,
        sourceId: 'jiosaavn',
        licenseType: LicenseType.custom,
        attributionString: '$artistName · JioSaavn',
        sourceUrl: 'https://www.jiosaavn.com/song/$title/${song['id']}',
        durationMs: durationMs,
        playCount: int.tryParse(song['play_count']?.toString() ?? '0') ?? 0,
        offlineAllowed: false,
        streamUrl: mediaUrl,
        genres: moreInfo['language'] != null ? [moreInfo['language'].toString()] : const [],
        language: moreInfo['language']?.toString() ?? 'hi',
      );
    } catch (e) {
      return null;
    }
  }

  // ── Searching ───────────────────────────────────────────────────────

  @override
  Future<List<Track>> searchTracks(
    String query, {
    int limit = 20,
    String? genre,
    String? language,
    bool isPodcast = false,
  }) async {
    try {
      final data = await _apiGet({
        '__call': 'search.getResults',
        'q': query,
        'p': 1,
        'n': limit,
      });

      final results = data['results'] ?? data['data']?['results'] ?? [];
      return (results as List)
          .map((e) => _parseTrack(e as Map<String, dynamic>))
          .whereType<Track>()
          .where((t) => isPodcast ? t.durationMs >= 600000 : t.durationMs < 600000)
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Track>> trending({
    String? genre,
    String? language,
    int limit = 20,
    bool isPodcast = false,
  }) async {
    try {
      final currentYear = DateTime.now().year;
      if (genre != null) {
        final genreMap = {
          'bollywood': 'latest bollywood hits $currentYear',
          'hip-hop': 'hip hop top hits $currentYear',
          'desi hip-hop': 'latest desi hip hop $currentYear',
          'electronic': 'edm top hits $currentYear',
          'english': 'latest english pop hits $currentYear',
          'global pop': 'global pop hits $currentYear',
          'kannada': 'latest kannada hit songs $currentYear',
          'classical': 'classical hit songs $currentYear',
          'rock': 'new rock hits $currentYear',
          'jazz': 'new jazz hits $currentYear',
          'punjabi': 'latest punjabi hits $currentYear',
          'ambient': 'ambient relaxing music $currentYear',
        };
        final query = genreMap[genre.toLowerCase()] ?? 'new $genre hits $currentYear';
        final tracks = await searchTracks(query, limit: limit, isPodcast: isPodcast);
        tracks.shuffle();
        return tracks;
      }

      final langMap = {
        'hindi': 'hindi',
        'english': 'english',
        'kannada': 'kannada',
        'tulu': 'kannada',
        'tamil': 'tamil',
        'telugu': 'telugu',
        'punjabi': 'punjabi',
        'marathi': 'marathi',
        'bengali': 'bengali',
      };

      final saavnLang = (language != null ? langMap[language.toLowerCase()] : null) ?? 'hindi';

      final data = await _apiGet({
        '__call': 'content.getAlbums',
        'p': 1,
        'n': limit,
        'language': saavnLang,
      });

      final albums = data['data'] ?? data['results'] ?? [];
      final trackFutures = (albums as List).take(5).map((a) => getAlbumTracks(a['id'].toString()));
      final trackArrays = await Future.wait(trackFutures);
      
      final List<Track> tracks = trackArrays.expand((e) => e).where((t) => isPodcast ? t.durationMs >= 600000 : t.durationMs < 600000).take(limit).toList();
      if (tracks.isNotEmpty) {
        tracks.shuffle();
        return tracks;
      }

      final query = saavnLang == 'hindi' ? 'new hindi songs $currentYear' :
                    saavnLang == 'kannada' ? 'new kannada songs $currentYear' :
                    saavnLang == 'tamil' ? 'new tamil songs $currentYear' :
                    saavnLang == 'telugu' ? 'new telugu songs $currentYear' :
                    saavnLang == 'punjabi' ? 'new punjabi songs $currentYear' :
                    'new songs $currentYear';
      final fallbackTracks = await searchTracks(query, limit: limit, isPodcast: isPodcast);
      fallbackTracks.shuffle();
      return fallbackTracks;
    } catch (e) {
      final query = language != null ? 'new $language hit songs ${DateTime.now().year}' : 'new hindi hit songs ${DateTime.now().year}';
      final fallbackTracks = await searchTracks(query, limit: limit, isPodcast: isPodcast);
      fallbackTracks.shuffle();
      return fallbackTracks;
    }
  }

  @override
  Future<List<Track>> getAlbumTracks(String albumId) async {
    try {
      final data = await _apiGet({
        '__call': 'content.getAlbumDetails',
        'albumid': albumId,
      });
      final songs = data['songs'] ?? data['list'] ?? [];
      return (songs as List).map((e) => _parseTrack(e as Map<String, dynamic>)).whereType<Track>().toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<String> resolveStreamUrl(String trackId, {String? title, String? artistName}) async {
    final nativeId = trackId.replaceFirst('jiosaavn:', '');
    try {
      final data = await _apiGet({
        '__call': 'song.getDetails',
        'pids': nativeId,
      });
      
      Map<String, dynamic>? song;
      if (data is Map && data.containsKey(nativeId) && data[nativeId] is Map) {
         song = data[nativeId] as Map<String, dynamic>;
      } else if (data is Map && data.containsKey('songs') && data['songs'] is List && (data['songs'] as List).isNotEmpty) {
         final firstSong = data['songs'][0];
         if (firstSong is Map) {
            song = firstSong as Map<String, dynamic>;
         }
      } else if (data is Map) {
         final possibleSong = data.values.whereType<Map<String, dynamic>>().firstOrNull;
         song = possibleSong;
      }
      
      if (song == null) throw Exception('Song not found or invalid format');
      
      final moreInfo = song['more_info'] ?? <String, dynamic>{};
      final url = _decodeMediaUrl(
        moreInfo['encrypted_media_url'] as String? ?? song['media_preview_url'] as String?,
        force320: moreInfo['320kbps'] == 'true' || moreInfo['320kbps'] == true,
      );
      
      if (url == null) throw Exception('No stream URL in response');
      return url;
    } catch (e) {
      throw Exception('[JioSaavn] Failed to resolve stream URL for $trackId: $e');
    }
  }

  @override
  Future<List<Artist>> searchArtists(String query, {int limit = 10}) async {
    try {
      final data = await _apiGet({
        '__call': 'search.getResults',
        'q': query,
        'p': 1,
        'n': limit,
      });

      // We actually need search.getArtistResults or just filter getResults for artists if the API supports it.
      // But JioSaavn API typically separates them or we can just fetch content.getArtistSearch.
      // Let's use the explicit artist search if possible, or fallback to returning empty for now.
      // Actually, JioSaavn has '__call': 'search.getArtistResults'
      final artistData = await _apiGet({
        '__call': 'search.getArtistResults',
        'q': query,
        'p': 1,
        'n': limit,
      });
      
      final results = artistData['results'] ?? artistData['data']?['results'] ?? [];
      return (results as List).map((e) {
        return Artist(
          id: e['id'].toString(),
          name: e['title']?.toString().replaceAll('&amp;', '&') ?? 'Unknown',
          sourceId: sourceId,
          avatarUrl: e['image']?.toString().replaceAll('150x150', '500x500'),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Track>> getArtistTracks(String artistId, {int limit = 20}) async {
    try {
      final data = await _apiGet({
        '__call': 'artist.getArtistMoreSong',
        'artistId': artistId,
        'p': 1,
        'n': limit,
      });

      final results = data['results'] ?? data['data']?['results'] ?? data['topSongs'] ?? [];
      return (results as List).map((e) => _parseTrack(e as Map<String, dynamic>)).whereType<Track>().toList();
    } catch (e) {
      return [];
    }
  }
}
