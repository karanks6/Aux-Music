import 'package:youtube_explode_dart/youtube_explode_dart.dart'; 
void main() async { 
  final yt = YoutubeExplode(); 
  try { 
    final manifest = await yt.videos.streamsClient.getManifest('dQw4w9WgXcQ'); 
    print(manifest.audioOnly.withHighestBitrate().url); 
  } catch(e, st) { 
    print(e); 
    print(st); 
  } finally { 
    yt.close(); 
  } 
}
