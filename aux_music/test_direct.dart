import 'dart:convert';
import 'dart:io';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
void main() async {
  var yt = YoutubeExplode();
  var manifest = await yt.videos.streamsClient.getManifest('dQw4w9WgXcQ');
  var streamInfo = manifest.audioOnly.withHighestBitrate();
  var url = streamInfo.url.toString();
  var client = HttpClient();
  var request = await client.getUrl(Uri.parse(url));
  request.headers.set('user-agent', 'com.google.android.youtube/20.10.38 (Linux; U; Android 11) gzip');
  request.headers.set('range', 'bytes=0-8191');
  var response = await request.close();
  print('Status: ${response.statusCode}');
  var bytes = await response.first;
  print('Got bytes: ${bytes.length}');
  yt.close();
}
