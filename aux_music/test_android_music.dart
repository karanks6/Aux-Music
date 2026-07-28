import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:io';
void main() async {
  final yt = YoutubeExplode();
  try {
    final manifest = await yt.videos.streamsClient.getManifest('kPa7bsKwL-c', ytClients: [YoutubeApiClient.android]);
    final url = manifest.audioOnly.withHighestBitrate().url.toString();
    print('Testing URL');
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set('user-agent', 'com.google.android.youtube/18.36.39 (Linux; U; Android 13; en_US) gzip');
    final response = await request.close();
    print('Response status: ' + response.statusCode.toString());
  } catch(e) {
    print('Error: ' + e.toString());
  } finally {
    yt.close();
  }
}
