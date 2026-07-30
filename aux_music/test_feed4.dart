import 'dart:io';
void main() async {
  try {
    final req = await HttpClient().getUrl(Uri.parse('https://feeds.npr.org/510325/podcast.xml'));
    final res = await req.close();
    print('HTTP ${res.statusCode}');
  } catch (e) {
    print('ERROR: $e');
  }
}
