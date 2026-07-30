import 'dart:io';
import 'dart:convert';

void main() async {
  final client = HttpClient();
  
  // 1. Get the stream URL from BFF
  final bffReq = await client.getUrl(Uri.parse('http://127.0.0.1:3000/stream-url/youtube_music/dQw4w9WgXcQ'));
  final bffRes = await bffReq.close();
  final bffBody = await bffRes.transform(utf8.decoder).join();
  final url = jsonDecode(bffBody)['streamUrl'];
  print('Got URL: ${url.substring(0, 100)}...');
  
  // 2. Test with standard ExoPlayer User-Agent
  final req1 = await client.getUrl(Uri.parse(url));
  req1.headers.set('user-agent', 'ExoPlayerDemo/2.18.7 (Linux; U; Android 14) ExoPlayerLib/2.18.7');
  final res1 = await req1.close();
  print('ExoPlayer UA: ${res1.statusCode}');
  
  // 3. Test with Dart User-Agent
  final req2 = await client.getUrl(Uri.parse(url));
  final res2 = await req2.close();
  print('Dart UA: ${res2.statusCode}');
  
  // 4. Test with ANDROID (youtube_explode) UA
  final req3 = await client.getUrl(Uri.parse(url));
  req3.headers.set('user-agent', 'com.google.android.youtube/18.36.39 (Linux; U; Android 13; en_US) gzip');
  final res3 = await req3.close();
  print('ANDROID UA: ${res3.statusCode}');
  
  // 5. Test with ANDROID_VR UA
  final req4 = await client.getUrl(Uri.parse(url));
  req4.headers.set('user-agent', 'com.google.android.apps.youtube.vr/1.54.26 (Linux; U; Android 13; en_US) gzip');
  final res4 = await req4.close();
  print('ANDROID_VR UA: ${res4.statusCode}');
  
  client.close();
}
