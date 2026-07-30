import 'dart:io';

void main() async {
  final feeds = [
    'https://feeds.megaphone.fm/VMP5705694065',
    'https://feeds.megaphone.fm/freakonomicsradio',
    'https://omny.fm/shows/freakonomics-radio/playlists/podcast.rss',
    'https://freakonomics.com/feed/'
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
