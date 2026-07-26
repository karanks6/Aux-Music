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

  String? _decodeMediaUrl(String? encodedUrl) {
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

      if (url.contains('_96.mp4')) url = url.replaceAll('_96.mp4', '_320.mp4');
      if (url.contains('_160.mp4')) url = url.replaceAll('_160.mp4', '_320.mp4');
      if (url.contains('_128.mp4')) url = url.replaceAll('_128.mp4', '_320.mp4');

      return url;
    } catch (e) {
      String url = encodedUrl
          .replaceAll('&amp;', '&')
          .replaceAllMapped(
            RegExp(r'https?:\/\/[^\/]*(aac\.saavncdn\.com|c\.saavncdn\.com)'),
            (m) => 'https://aac.saavncdn.com',
          );
      if (url.contains('_96.mp4')) url = url.replaceAll('_96.mp4', '_320.mp4');
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
      final mediaUrl = _decodeMediaUrl(moreInfo['encrypted_media_url'] as String? ?? song['media_preview_url'] as String?);
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
  }) async {
    try {
      final data = await _apiGet({
        '__call': 'search.getResults',
        'q': query,
        'p': 1,
        'n': limit,
      });

      final results = data['results'] ?? data['data']?['results'] ?? [];
      return (results as List).map((e) => _parseTrack(e as Map<String, dynamic>)).whereType<Track>().toList();
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
  }) async {
    try {
      if (genre != null) {
        final genreMap = {
          'bollywood': 'latest bollywood hits',
          'hip-hop': 'hip hop top hits',
          'desi hip-hop': 'desi hip hop',
          'electronic': 'edm top hits',
          'english': 'latest english pop hits',
          'global pop': 'global pop hits',
          'kannada': 'kannada hit songs',
          'classical': 'classical hit songs',
          'rock': 'rock hits',
          'jazz': 'jazz hits',
          'punjabi': 'latest punjabi hits',
          'ambient': 'ambient relaxing music',
        };
        final query = genreMap[genre.toLowerCase()] ?? '$genre hits';
        return searchTracks(query, limit: limit);
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
      
      final List<Track> tracks = trackArrays.expand((e) => e).take(limit).toList();
      if (tracks.isNotEmpty) return tracks;

      final query = saavnLang == 'hindi' ? 'new hindi songs 2024' :
                    saavnLang == 'kannada' ? 'new kannada songs 2024' :
                    saavnLang == 'tamil' ? 'new tamil songs 2024' :
                    saavnLang == 'telugu' ? 'new telugu songs 2024' :
                    saavnLang == 'punjabi' ? 'new punjabi songs 2024' :
                    'new songs 2024';
      return searchTracks(query, limit: limit);
    } catch (e) {
      final query = language != null ? 'new $language hit songs' : 'new hindi hit songs';
      return searchTracks(query, limit: limit);
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
  Future<String> resolveStreamUrl(String trackId) async {
    final nativeId = trackId.replaceFirst('jiosaavn:', '');
    try {
      final data = await _apiGet({
        '__call': 'song.getDetails',
        'pids': nativeId,
      });
      
      final song = data[nativeId] ?? (data as Map).values.firstOrNull;
      if (song == null) throw Exception('Song not found');
      
      final moreInfo = song['more_info'] ?? <String, dynamic>{};
      final url = _decodeMediaUrl(moreInfo['encrypted_media_url'] as String? ?? song['media_preview_url'] as String?);
      
      if (url == null) throw Exception('No stream URL in response');
      return url;
    } catch (e) {
      throw Exception('[JioSaavn] Failed to resolve stream URL for $trackId: $e');
    }
  }

  @override
  Future<List<Artist>> searchArtists(String query, {int limit = 10}) async {
    return [];
  }

  @override
  Future<List<Track>> getArtistTracks(String artistId, {int limit = 20}) async {
    return [];
  }
}
