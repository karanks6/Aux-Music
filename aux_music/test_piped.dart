import 'dart:convert';
import 'dart:io';

void main() async {
  final instances = [
    'pipedapi.kavin.rocks',
    'pipedapi.drgns.space',
    'pipedapi.lunar.icu',
    'piped-api.garudalinux.org',
    'api.piped.projectsegfau.lt',
  ];
  
  final videoId = 'dQw4w9WgXcQ';
  
  for (final instance in instances) {
    try {
      print('Testing $instance...');
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('https://$instance/streams/$videoId'));
      request.headers.set('User-Agent', 'Mozilla/5.0');
      
      final response = await request.close().timeout(Duration(seconds: 5));
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body);
        if (json['audioStreams'] != null && (json['audioStreams'] as List).isNotEmpty) {
           print('SUCCESS: $instance works! Stream URL: ${json['audioStreams'][0]['url']}');
        } else {
           print('FAILED: $instance (No audio streams)');
        }
      } else {
        print('FAILED: $instance (Status ${response.statusCode})');
      }
    } catch (e) {
      print('FAILED: $instance (Error: $e)');
    }
  }
}
