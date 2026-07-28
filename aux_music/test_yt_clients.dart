import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() async {
  var yt = YoutubeExplode();
  try {
    var manifest = await yt.videos.streamsClient.getManifest('dQw4w9WgXcQ', ytClients: [YoutubeApiClient.tv]);
    var streamInfo = manifest.audioOnly.withHighestBitrate();
    print('TV Stream URL: ${streamInfo.url}');
  } catch (e) {
    print('TV Failed: $e');
  }
  
  try {
    var manifest = await yt.videos.streamsClient.getManifest('dQw4w9WgXcQ', ytClients: [YoutubeApiClient.ios]);
    var streamInfo = manifest.audioOnly.withHighestBitrate();
    print('IOS Stream URL: ${streamInfo.url}');
  } catch (e) {
    print('IOS Failed: $e');
  }
  yt.close();
}
