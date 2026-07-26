import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import 'package:dio/dio.dart';
import '../models/track.dart';
import '../models/artist.dart';
import '../models/license_type.dart';
import 'music_source_adapter.dart';

class YouTubeMusicAdapter implements MusicSourceAdapter {
  final yt.YoutubeExplode _yt = yt.YoutubeExplode();
  final Dio _dio = Dio();

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

  @override
  Future<List<Track>> searchTracks(
    String query, {
    int limit = 20,
    String? genre,
    String? language,
  }) async {
    try {
      String finalQuery = query;
      if (query.isEmpty && genre != null) {
        finalQuery = '$genre top hits';
      } else if (query.isEmpty && language != null) {
        finalQuery = '$language top hits';
      }
      
      final results = await _yt.search.search(finalQuery);
      return results.take(limit).map((v) => _parseVideo(v)).whereType<Track>().toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Track>> trending({
    String? genre,
    String? language,
    int limit = 20,
  }) async {
    try {
      String query = 'global top 50 songs';
      if (genre != null) {
        query = '$genre hit songs';
      } else if (language != null) {
        query = 'top $language songs';
      }
      
      final results = await _yt.search.search(query);
      return results.take(limit).map((v) => _parseVideo(v)).whereType<Track>().toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<String> resolveStreamUrl(String trackId) async {
    final nativeId = trackId.replaceFirst('youtube_music:', '');
    
    // Using a reliable Invidious instance to proxy the audio stream directly.
    // This bypasses ExoPlayer 403s on googlevideo.com and avoids local proxy crashes.
    // itag=251 is highest quality Opus audio.
    return 'https://inv.tux.pizza/latest_version?id=$nativeId&itag=251';
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
    // Test a basic search
    final results = await _yt.search.search('adele');
    if (results.isEmpty) throw Exception('YouTube Music returned no results');
  }
}
