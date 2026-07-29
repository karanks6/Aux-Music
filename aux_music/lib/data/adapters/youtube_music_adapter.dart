import 'dart:convert';
import 'dart:io';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import '../models/track.dart';
import '../models/artist.dart';
import '../models/license_type.dart';
import 'music_source_adapter.dart';
import '../../core/proxy/local_audio_proxy.dart';

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

  @override
  Future<String> resolveStreamUrl(String trackId) async {
    final nativeId = trackId.replaceFirst('youtube_music:', '');
    
    // Check in-memory cache first to prevent rate-limiting on repeat plays
    if (_streamCache.containsKey(nativeId)) {
      print('[YouTubeMusic] Returning cached stream URL for $nativeId');
      return _streamCache[nativeId]!;
    }
    
    // Fetch the stream manifest directly using the client-side library.
    // IMPORTANT: We must use the iOS client to generate the manifest, because
    // YoutubeStreamAudioSource hardcodes the iOS User-Agent. If they mismatch,
    // YouTube returns 403 Forbidden!
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(
        nativeId,
        ytClients: [yt.YoutubeApiClient.ios]
      );
      
      final formats = manifest.audioOnly;
      
      if (formats.isNotEmpty) {
        final streamInfo = formats.withHighestBitrate();
        final url = streamInfo.url.toString();
        final size = streamInfo.size.totalBytes;
        
        // Encode the URL as base64 to pass it safely in the custom ytstream protocol
        final encodedUrl = base64Url.encode(utf8.encode(url));
        final ytStreamUrl = 'ytstream://stream?url=$encodedUrl&length=$size';
        
        // Cache the successful resolution
        _streamCache[nativeId] = ytStreamUrl;
        
        return ytStreamUrl;
      } else {
        throw Exception('No audio streams found for $nativeId');
      }
    } catch (e) {
      print('[YouTubeMusic] Native stream resolution failed: $e. Falling back to Piped API...');
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
                 print('[YouTubeMusic] Piped API fallback successful with $instance! URL: $url');
                 
                 _streamCache[nativeId] = url;
                 return url;
              }
            }
          } catch (pipedError) {
            print('[YouTubeMusic] Piped instance $instance failed.');
          }
        }
        print('[YouTubeMusic] All Piped instances failed.');

      // If YouTube rate-limits the client (e.g. RequestLimitExceededException), 
      // we throw so the aggregator can seamlessly fall back to JioSaavn.
      throw Exception('YouTube stream resolution failed completely: $e');
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
