import 'package:youtube_explode_dart/youtube_explode_dart.dart';
void main() async {
  var yt = YoutubeExplode();
  var t = DateTime.now();
  print('Searching...');
  try {
    var results = await yt.search.search('never gonna give you up');
    print('Found ${results.length} results in ${DateTime.now().difference(t).inMilliseconds}ms');
  } catch (e) {
    print('Error: $e');
  }
  yt.close();
}
