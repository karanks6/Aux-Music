import 'dart:io';
import 'dart:convert';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class LocalAudioProxy {
  static final LocalAudioProxy _instance = LocalAudioProxy._internal();
  factory LocalAudioProxy() => _instance;
  LocalAudioProxy._internal();

  final YoutubeExplode _yt = YoutubeExplode();
  HttpServer? _server;
  final Map<String, StreamInfo> _prefetchedStreams = {};

  void prefetchStream(String videoId, StreamInfo info) {
    _prefetchedStreams[videoId] = info;
  }

  Future<void> start() async {
    if (_server != null) return;
    try {
      _server = await HttpServer.bind('127.0.0.1', 0);
      _server!.listen((HttpRequest request) async {
        if (request.uri.path == '/direct') {
          final encodedUrl = request.uri.queryParameters['url'];
          if (encodedUrl == null) {
            request.response.statusCode = 400;
            await request.response.close();
            return;
          }
          
          try {
            final targetUrl = utf8.decode(base64Url.decode(encodedUrl));
            final client = HttpClient();
            final streamRequest = await client.getUrl(Uri.parse(targetUrl));
            
            final range = request.headers.value('range');
            if (range != null) {
              streamRequest.headers.set('range', range);
            }
            
            // Use the iOS YouTube User-Agent to match the YoutubeApiClient.ios client used by youtube_explode_dart.
            if (targetUrl.contains('googlevideo.com')) {
              streamRequest.headers.set('user-agent', 'com.google.ios.youtube/19.29.1 (iPhone16,2; U; CPU iOS 17_5_1 like Mac OS X)');
            } else {
              streamRequest.headers.set('user-agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.18 Safari/537.36');
            }
            
            streamRequest.headers.set('cookie', 'CONSENT=YES+cb');
            streamRequest.headers.set('accept', '*/*');
            streamRequest.headers.set('accept-language', 'en-US,en;q=0.9');

            print('[LocalAudioProxy] Fetching: $targetUrl');
            
            final streamResponse = await streamRequest.close();
            print('[LocalAudioProxy] Response Status: ${streamResponse.statusCode}');
            
            request.response.statusCode = streamResponse.statusCode;
            streamResponse.headers.forEach((name, values) {
              for (var value in values) {
                request.response.headers.add(name, value);
              }
            });

            await streamResponse.pipe(request.response);
          } catch (e) {
            print('[LocalAudioProxy] Error proxying direct stream: $e');
            request.response.statusCode = 500;
            await request.response.close();
          }
          return;
        }

        final videoId = request.uri.queryParameters['id'];
        if (videoId == null) {
          request.response.statusCode = 400;
          await request.response.close();
          return;
        }

        try {
          dynamic streamInfo = _prefetchedStreams[videoId];
          
          if (streamInfo == null) {
            final manifest = await _yt.videos.streamsClient.getManifest(videoId);
            if (manifest.audioOnly.isNotEmpty) {
              streamInfo = manifest.audioOnly.withHighestBitrate();
            } else if (manifest.audio.isNotEmpty) {
              streamInfo = manifest.audio.withHighestBitrate();
            } else {
              request.response.statusCode = 404;
              await request.response.close();
              return;
            }
          }

          // Fetch the stream natively via youtube_explode_dart
          // This handles ALL of YouTube's proprietary headers and ciphers natively
          final audioStream = _yt.videos.streamsClient.get(streamInfo as StreamInfo);

          // We must supply the content length so ExoPlayer can cache it
          request.response.statusCode = 200;
          request.response.headers.add('content-type', streamInfo.codec.mimeType);
          request.response.headers.add('content-length', streamInfo.size.totalBytes);
          request.response.headers.add('accept-ranges', 'bytes');

          await audioStream.pipe(request.response);
        } catch (e) {
          print('[LocalAudioProxy] Error proxying stream natively: $e');
          request.response.statusCode = 500;
          await request.response.close();
        }
      });
      print('[LocalAudioProxy] Started on port ${_server!.port}');
    } catch (e) {
      print('[LocalAudioProxy] Failed to start: $e');
    }
  }

  String getProxyUrl(String videoId) {
    if (_server == null) throw StateError('Proxy server not started');
    return 'http://127.0.0.1:${_server!.port}/proxy?id=$videoId';
  }

  String getProxyUrlForDirect(String encodedUrl) {
    if (_server == null) throw StateError('Proxy server not started');
    return 'http://127.0.0.1:${_server!.port}/direct?url=$encodedUrl';
  }
}
