import 'dart:convert';
import 'dart:io';

void main() async {
  final instances = [
    'invidious.jing.rocks',
    'inv.tux.pizza',
    'invidious.nerdvpn.de',
  ];
  
  final videoId = 'kPa7bsKwL-c';
  
  for (final instance in instances) {
    try {
      print('Testing $instance...');
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('https://$instance/api/v1/videos/$videoId'));
      final response = await request.close().timeout(Duration(seconds: 5));
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body);
        print('SUCCESS: $instance works! length: ');
      } else {
        print('FAILED: $instance (Status )');
      }
    } catch (e) {
      print('FAILED: $instance (Error: $e)');
    }
  }
}
