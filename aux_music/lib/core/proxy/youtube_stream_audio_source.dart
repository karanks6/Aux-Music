import 'dart:io';
import 'package:just_audio/just_audio.dart';

class YoutubeStreamAudioSource extends StreamAudioSource {
  final String url;
  final int sourceLength;
  
  YoutubeStreamAudioSource({
    required this.url, 
    required this.sourceLength, 
    super.tag,
  });

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    
    // Inject the Android YouTube User-Agent to match youtube_explode_dart
    request.headers.set('user-agent', 'com.google.android.youtube/18.36.39 (Linux; U; Android 13; en_US) gzip');
    
    if (start != null || end != null) {
      request.headers.set('range', 'bytes=${start ?? 0}-${end != null ? end : ''}');
    }
    
    final response = await request.close();
    
    print('[YoutubeStreamAudioSource] YouTube response: ${response.statusCode} for range ${start ?? 0}-${end != null ? end : ''}');
    
    if (response.statusCode == 403) {
      print('[YoutubeStreamAudioSource] WARNING: Got 403 Forbidden! BotGuard blocked the stream.');
    }
    
    return StreamAudioResponse(
      sourceLength: sourceLength,
      contentLength: response.contentLength,
      offset: start ?? 0,
      stream: response,
      contentType: response.headers.contentType?.mimeType ?? 'audio/webm',
    );
  }
}
