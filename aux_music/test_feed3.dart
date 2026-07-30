import 'dart:io';
void main() async {
  try {
    final req = await HttpClient().getUrl(Uri.parse('https://www.marketplace.org/feed/podcast/marketplace'));
    final res = await req.close();
    print('HTTP ${res.statusCode}');
  } catch (e) {
    print('ERROR: $e');
  }
}
