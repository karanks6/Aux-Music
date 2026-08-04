import 'dart:convert';
import 'dart:io';
import 'package:aux_music/core/node_server/node_server_service.dart';
import 'package:aux_music/core/proxy/local_audio_proxy.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import '../models/track.dart';
import '../models/artist.dart';
import '../models/license_type.dart';
import 'music_source_adapter.dart';
import '../../core/config/env.dart';
import 'package:dio/dio.dart' as dio;
import '../../services/po_token_service.dart';

class YouTubeMusicAdapter implements MusicSourceAdapter {
  final yt.YoutubeExplode _yt = yt.YoutubeExplode();
  
  // In-memory cache to prevent repeatedly requesting the same stream URL, 
  // which can rapidly trigger YouTube's rate-limiting on the user's IP.
  static final Map<String, String> _streamCache = {};

  @override
  String get sourceId => 'youtube_music';

  @override
  String get displayName => 'YouTube Music';

  @override
  bool get isEnabled => true; // Active

  @override
  Future<void> initialize() async {}

  Track? _parseVideo(yt.Video video) {
    return Track(
      id: 'youtube_music:${video.id.value}',
      title: video.title,
      artistName: video.author,
      artistId: 'youtube_music_artist:${video.channelId.value}',
      albumName: '',
      artworkUrl: video.thumbnails.highResUrl,
      thumbnailUrl: video.thumbnails.lowResUrl,
      sourceId: sourceId,
      licenseType: LicenseType.custom,
      attributionString: '${video.author} · YouTube',
      sourceUrl: video.url,
      durationMs: video.duration?.inMilliseconds ?? 0,
      playCount: 0,
      offlineAllowed: false,
      streamUrl: null,
      genres: const [],
      language: '',
    );
  }

  Future<Track?> getTrackDetails(String trackId) async {
    try {
      final nativeId = trackId.replaceFirst('youtube_music:', '');
      final video = await _yt.videos.get(nativeId);
      return _parseVideo(video);
    } catch (e) {
      return null;
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
    try {
      String finalQuery = query;
      if (query.isEmpty && genre != null) {
        finalQuery = '$genre top hits';
      } else if (query.isEmpty && language != null) {
        finalQuery = '$language top hits';
      }
      
      final results = await _yt.search.search(finalQuery);
      return results.map((v) => _parseVideo(v))
          .whereType<Track>()
          .where((t) => isPodcast ? t.durationMs >= 600000 : t.durationMs < 600000)
          .take(limit)
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
      String query = 'global top 50 songs $currentYear';
      if (genre != null) {
        query = 'latest $genre hit songs $currentYear';
      } else if (language != null) {
        query = 'latest top $language songs $currentYear';
      }
      
      final results = await _yt.search.search(query);
      
      final tracks = results.map((v) => _parseVideo(v))
          .whereType<Track>()
          .where((t) => isPodcast ? t.durationMs >= 600000 : t.durationMs < 600000)
          .take(limit)
          .toList();
          
      tracks.shuffle();
      return tracks;
    } catch (e) {
      return [];
    }
  }

  Future<List<Track>> getUpNext(String trackId) async {
    try {
      final nativeId = trackId.replaceFirst('youtube_music:', '');
      final bffResponse = await dio.Dio().get(
        '${Env.bffUrl}/recommendations/upnext/$nativeId',
      );
      if (bffResponse.statusCode == 200) {
        final data = bffResponse.data['data'] as List;
        return data.map((t) => Track.fromJson(t)).toList();
      }
    } catch (e) {
      print('[YouTubeMusic] getUpNext error: $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getHomeRecommendations() async {
    try {
      final bffResponse = await dio.Dio().get(
        '${Env.bffUrl}/recommendations/home',
      );
      if (bffResponse.statusCode == 200) {
        final data = bffResponse.data['data'] as List;
        return data.map((shelf) {
          final tracksList = shelf['tracks'] as List;
          final tracks = tracksList.map((t) => Track.fromJson(t)).toList();
          return {
            'title': shelf['title'] as String,
            'tracks': tracks,
          };
        }).toList();
      }
    } catch (e) {
      print('[YouTubeMusic] getHomeRecommendations error: $e');
    }
    return [];
  }

    @override
    Future<String> resolveStreamUrl(String trackId) async {
      final nativeId = trackId.replaceFirst('youtube_music:', '');
      
      // Check in-memory cache first to prevent rate-limiting on repeat plays
      if (_streamCache.containsKey(nativeId)) {
        final cachedUrl = _streamCache[nativeId]!;
        if (!cachedUrl.startsWith('http://127.0.0.1') && !cachedUrl.contains('piped')) {
          print('[YouTubeMusic] Invalidating old broken cache for $nativeId');
          _streamCache.remove(nativeId);
        } else {
          print('[YouTubeMusic] Returning cached stream URL for $nativeId');
          return cachedUrl;
        }
      }

      // 1. Try Piped API FIRST (Most reliable for bypassing BotGuard currently)
      final pipedInstances = [
        'https://piped.projectsegfau.lt/api',
        'https://pipedapi.kavin.rocks',
        'https://pipedapi.smnz.de',
        'https://piped-api.garudalinux.org',
        'https://piped-api.lunar.icu',
      ];

      for (final instance in pipedInstances) {
        try {
          print('[YouTubeMusic] Trying Piped instance: $instance');
          final request = await HttpClient().getUrl(Uri.parse('$instance/streams/$nativeId'));
          final response = await request.close().timeout(const Duration(seconds: 3));
          if (response.statusCode == 200) {
            final body = await response.transform(utf8.decoder).join();
            final json = jsonDecode(body);
            final audioStreams = json['audioStreams'] as List<dynamic>?;
            
            if (audioStreams != null && audioStreams.isNotEmpty) {
               final bestStream = audioStreams.reduce((a, b) => (a['bitrate'] ?? 0) > (b['bitrate'] ?? 0) ? a : b);
               final url = bestStream['url'] as String;
               print('[YouTubeMusic] Piped API resolution successful with $instance!');
               
               _streamCache[nativeId] = url;
               return url;
            }
          }
        } catch (pipedError) {
          print('[YouTubeMusic] Piped instance $instance failed.');
        }
      }
      
      // 2. Try BFF (Node backend) Proxy as fallback
      try {
        print('[YouTubeMusic] Trying BFF Proxy fallback: ${Env.bffUrl}');
        
        final poTokenSvc = PoTokenService();
        await poTokenSvc.init(); // Wait for token extraction to finish (or timeout)
        final poToken = poTokenSvc.poToken ?? '';
        final visitorData = poTokenSvc.visitorData ?? '';
        
        final proxyUrl = '${Env.bffUrl}/proxy-stream/youtube_music/$nativeId?poToken=$poToken&visitorData=$visitorData';
        
        // Do a quick HEAD request to ensure the backend can resolve and start streaming
        // before we hand the URL off to ExoPlayer.
        final checkResponse = await dio.Dio().head(
          proxyUrl,
          options: dio.Options(
            sendTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
            validateStatus: (status) => status != null && status < 400,
          ),
        );
        
        if (checkResponse.statusCode == 200 || checkResponse.statusCode == 206) {
          print('[YouTubeMusic] BFF Proxy extraction successful!');
          _streamCache[nativeId] = proxyUrl;
          return proxyUrl;
        }
      } catch (bffError) {
        print('[YouTubeMusic] BFF Proxy failed: $bffError');
      }
      
      // 3. Try Native youtube_explode_dart (Fallback 2)
      try {
        final manifest = await _yt.videos.streamsClient.getManifest(
          nativeId,
          ytClients: [
            yt.YoutubeApiClient.android, 
            yt.YoutubeApiClient.androidVr, 
            yt.YoutubeApiClient.tv
          ]
        );
        
        final formats = manifest.audioOnly;
        
        if (formats.isNotEmpty) {
          final streamInfo = formats.withHighestBitrate();
          final url = streamInfo.url.toString();
          final size = streamInfo.size.totalBytes;
          
          final encodedUrl = base64Url.encode(utf8.encode(url));
          final proxySvc = LocalAudioProxy();
          final proxyUrl = proxySvc.getProxyUrlForDirect(encodedUrl);
          
          _streamCache[nativeId] = proxyUrl;
          return proxyUrl;
        }
      } catch (e) {
        print('[YouTubeMusic] Native stream resolution failed: $e');
      }
      
      throw Exception('YouTube stream resolution failed completely for $nativeId');
    }

  @override
  Future<List<Artist>> searchArtists(String query, {int limit = 10}) async {
    return [];
  }

  @override
  Future<List<Track>> getArtistTracks(String artistId, {int limit = 20}) async {
    return []; 
  }

  @override
  Future<List<Track>> getAlbumTracks(String albumId) async {
    return []; 
  }

  @override
  Future<void> healthCheck() async {
    // Disabled native youtube_explode_dart health check because devices with
    // ad-blockers or private DNS often block www.youtube.com, which would
    // cause the aggregator to mark YouTube as dead and refuse to play cached songs!
    return;
  }
}
