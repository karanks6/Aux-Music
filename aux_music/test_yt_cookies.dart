import 'package:youtube_explode_dart/youtube_explode_dart.dart';
void main() async {
  var yt = YoutubeExplode();
  var manifest = await yt.videos.streamsClient.getManifest('dQw4w9WgXcQ');
  print('Stream URL: \');
  yt.close();
}
