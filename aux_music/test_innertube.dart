import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  final req = await client.postUrl(Uri.parse('https://youtubei.googleapis.com/youtubei/v1/player'));
  req.headers.set('Content-Type', 'application/json');
  req.headers.set('User-Agent', 'com.google.ios.youtube/19.29.1 (iPhone15,2; U; CPU iOS 17_5_1 like Mac OS X; en_US)');
  req.headers.set('X-Goog-Api-Format-Version', '2');
  
  req.add(utf8.encode(jsonEncode({
    'context': {
      'client': {
        'clientName': 'IOS',
        'clientVersion': '19.29.1',
        'hl': 'en',
        'gl': 'US',
        'deviceMake': 'Apple',
        'deviceModel': 'iPhone15,2',
        'osName': 'iPhone',
        'osVersion': '17.5.1'
      }
    },
    'videoId': 'dQw4w9WgXcQ',
    'playbackContext': {
      'contentPlaybackContext': {
        'html5Preference': 'HTML5_PREF_WANTS'
      }
    },
    'contentCheckOk': true,
    'racyCheckOk': true
  })));
  
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  print(body);
}
