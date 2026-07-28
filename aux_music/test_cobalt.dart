import 'dart:convert';
import 'dart:io';

void main() async {
  var client = HttpClient();
  
  try {
    var req = await client.postUrl(Uri.parse('https://api.cobalt.tools/api/json'));
    req.headers.set('accept', 'application/json');
    req.headers.set('content-type', 'application/json');
    req.headers.set('user-agent', 'AuxMusic/1.0.0'); // Cobalt requires user agent
    
    req.write(jsonEncode({
      'url': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      'isAudioOnly': true,
      'aFormat': 'best'
    }));
    
    var res = await req.close();
    var body = await res.transform(utf8.decoder).join();
    print('Status: ${res.statusCode}');
    print('Body: $body');
  } catch (e) {
    print('Failed: $e');
  }
}
