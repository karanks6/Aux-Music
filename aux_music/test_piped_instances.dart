import 'dart:convert';
import 'dart:io';

void main() async {
  var client = HttpClient();
  
  var instances = [
    'https://pipedapi.kavin.rocks',
    'https://api.piped.projectsegfau.lt',
    'https://pipedapi.smarthome-zone.de'
  ];
  
  for (var instance in instances) {
    try {
      print('Testing $instance...');
      var req = await client.getUrl(Uri.parse('$instance/streams/dQw4w9WgXcQ'));
      var res = await req.close();
      if (res.statusCode == 200) {
        var body = await res.transform(utf8.decoder).join();
        var data = jsonDecode(body);
        var audioStreams = data['audioStreams'] as List;
        print('Found ${audioStreams.length} audio streams');
        var url = audioStreams[0]['url'];
        print('Stream URL: $url');
        break;
      } else {
        print('Error: ${res.statusCode}');
      }
    } catch (e) {
      print('Failed: $e');
    }
  }
}
