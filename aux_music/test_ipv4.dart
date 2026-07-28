import 'dart:io';

class IPv4HttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.connectionFactory = (Uri uri, String? proxyHost, int? proxyPort) async {
      final ips = await InternetAddress.lookup(uri.host);
      final ipv4 = ips.firstWhere((ip) => ip.type == InternetAddressType.IPv4);
      final socket = await Socket.connect(ipv4.address, uri.port);
      return ConnectionTask.fromSocket(Future.value(socket), () => socket.close());
    };
    return client;
  }
}

void main() async {
  HttpOverrides.global = IPv4HttpOverrides();
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => true;
  final req = await client.getUrl(Uri.parse('https://www.youtube.com'));
  final res = await req.close();
  print(res.statusCode);
}
