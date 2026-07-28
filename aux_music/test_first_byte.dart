import 'package:youtube_explode_dart/youtube_explode_dart.dart';
void main() async {
  var yt = YoutubeExplode();
  var manifest = await yt.videos.streamsClient.getManifest('dQw4w9WgXcQ');
  var streamInfo = manifest.audioOnly.withHighestBitrate();
  var t = DateTime.now();
  var stream = yt.videos.streamsClient.get(streamInfo);
  var firstChunk = await stream.first;
  print('First chunk in ${DateTime.now().difference(t).inMilliseconds}ms');
  yt.close();
}
