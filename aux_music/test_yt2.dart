import 'package:youtube_explode_dart/youtube_explode_dart.dart';
void main() async {
  var yt = YoutubeExplode();
  var manifest = await yt.videos.streamsClient.getManifest('dQw4w9WgXcQ');
  var streamInfo = manifest.audioOnly.withHighestBitrate();
  print('Stream URL: ${streamInfo.url}');
  try {
    var stream = yt.videos.streamsClient.get(streamInfo);
    var firstChunk = await stream.first;
    print('Got bytes: ${firstChunk.length}');
  } catch(e) {
    print('Error getting bytes: $e');
  }
  yt.close();
}
