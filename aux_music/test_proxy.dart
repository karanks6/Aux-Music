import 'dart:io';
import 'lib/core/proxy/local_audio_proxy.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() async {
  final yt = YoutubeExplode();
  final proxy = LocalAudioProxy();
  await proxy.start();
  
  final manifest = await yt.videos.streamsClient.getManifest('dQw4w9WgXcQ');
  final url = manifest.audioOnly.withHighestBitrate().url.toString();
  
  final proxyUrl = proxy.getProxyUrl(url);
  print('Proxy URL: ' + proxyUrl);
  
  final client = HttpClient();
  final request = await client.getUrl(Uri.parse(proxyUrl));
  final response = await request.close();
  print('Status: ' + response.statusCode.toString());
  print('Length: ' + response.contentLength.toString());
  
  yt.close();
  exit(0);
}
