import 'dart:io';

void main() async {
  final feeds = [
    'https://feeds.simplecast.com/7123pI11',
    'https://lexfridman.com/feed/podcast/',
    'https://feeds.megaphone.fm/vergecast',
    'https://feeds.simplecast.com/dHoohVNH',
    'https://rss.art19.com/smartless',
    'https://wtfpod.libsyn.com/rss',
    'https://feeds.simplecast.com/54nAGcIl',
    'https://feeds.npr.org/510318/podcast.xml',
    'https://podcasts.files.bbci.co.uk/p02nq0gn.rss',
    'https://feeds.npr.org/510289/podcast.xml',
    'https://feeds.simplecast.com/s6wEExXo',
    'https://feeds.npr.org/510313/podcast.xml'
  ];

  for (final feed in feeds) {
    try {
      final req = await HttpClient().getUrl(Uri.parse(feed));
      final res = await req.close();
      print('HTTP ${res.statusCode}: $feed');
    } catch (e) {
      print('ERROR: $feed -> $e');
    }
  }
}
