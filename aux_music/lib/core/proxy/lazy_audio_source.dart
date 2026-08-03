import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class LazyAudioSource extends StreamAudioSource {
  final Future<String> Function() resolveUrl;
  final Map<String, String>? headers;
  String? _resolvedUrl;

  LazyAudioSource({
    required this.resolveUrl,
    this.headers,
    super.tag,
  });

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    _resolvedUrl ??= await resolveUrl();
    
    if (_resolvedUrl!.startsWith('file://')) {
      final file = File(_resolvedUrl!.replaceFirst('file://', ''));
      final length = await file.length();
      final stream = file.openRead(start ?? 0, end);
      return StreamAudioResponse(
        sourceLength: length,
        contentLength: (end != null ? end - (start ?? 0) : length - (start ?? 0)),
        offset: start ?? 0,
        stream: stream,
        contentType: 'audio/mpeg',
      );
    }
    
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(_resolvedUrl!));
    
    headers?.forEach((key, value) {
      request.headers.set(key, value);
    });
    
    if (start != null || end != null) {
      request.headers.set('range', 'bytes=${start ?? 0}-${end != null ? end : ''}');
    }
    
    final response = await request.close();
    
    return StreamAudioResponse(
      sourceLength: null, 
      contentLength: response.contentLength > 0 ? response.contentLength : null,
      offset: start ?? 0,
      stream: response,
      contentType: response.headers.contentType?.mimeType ?? 'audio/webm',
    );
  }
}
