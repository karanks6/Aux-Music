import 'dart:convert';
import 'dart:io';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
void main() async {
  var yt = YoutubeExplode();
  var manifest = await yt.videos.streamsClient.getManifest('dQw4w9WgXcQ', ytClients: [YoutubeApiClient.ios]);
  var streamInfo = manifest.audioOnly.withHighestBitrate();
  var url = streamInfo.url.toString();
  var client = HttpClient();
  var request = await client.getUrl(Uri.parse(url));
  request.headers.set('user-agent', 'com.google.ios.youtube/19.29.1 (iPhone16,2; U; CPU iOS 17_5_1 like Mac OS X)');
  request.headers.set('range', 'bytes=0-8191');
  var response = await request.close();
  print('Status: \');
  var bytes = await response.first;
  print('Got bytes: \');
  yt.close();
}
