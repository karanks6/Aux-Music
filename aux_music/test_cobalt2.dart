import "dart:convert";
import "dart:io";

void main() async {
  var client = HttpClient();
  var urls = [
    "https://co.wuk.sh/api/json",
    "https://cobalt.q0.is/api/json",
    "https://api.cobalt.tools/api/json"
  ];
  for (var u in urls) {
    try {
      var req = await client.postUrl(Uri.parse(u));
      req.headers.set("accept", "application/json");
      req.headers.set("content-type", "application/json");
      req.write(jsonEncode({"url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ", "isAudioOnly": true}));
      var res = await req.close();
      var body = await res.transform(utf8.decoder).join();
      print("$u -> ${res.statusCode} : $body");
    } catch(e) { print("$u -> Failed: $e"); }
  }
}
