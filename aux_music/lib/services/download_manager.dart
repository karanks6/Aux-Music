import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../data/repositories/library_repository.dart';
import '../data/adapters/adapter_aggregator.dart';
import '../core/providers/library_providers.dart';
import '../data/models/track.dart';
import '../core/di/providers.dart';

final downloadManagerProvider = Provider<DownloadManager>((ref) {
  return DownloadManager(
    ref.watch(libraryRepositoryProvider),
    ref.watch(aggregatorProvider),
  );
});

class DownloadManager {
  final LibraryRepository _library;
  final MusicAdapterAggregator _aggregator;
  final Dio _dio = Dio();
  final Set<String> _downloading = {};

  DownloadManager(this._library, this._aggregator);

  bool isDownloading(String trackId) => _downloading.contains(trackId);

  Future<void> downloadTrack(Track track) async {
    if (_downloading.contains(track.id)) {
      throw Exception('Already downloading');
    }
    
    // Check if already downloaded
    final existing = await _library.getDownload(track.id);
    if (existing != null && File(existing.localPath).existsSync()) {
      throw Exception('Already downloaded');
    }

    try {
      _downloading.add(track.id);

      // Resolve URL
      final url = await _aggregator.resolveStreamUrl(track.id);
      
      // Get safe local path
      final dir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory(p.join(dir.path, 'aux_downloads'));
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      
      final safeId = track.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final localPath = p.join(downloadsDir.path, '$safeId.mp3');

      // Download
      final response = await _dio.download(url, localPath);
      
      if (response.statusCode == 200) {
        final file = File(localPath);
        final size = await file.length();
        await _library.markDownloaded(track, localPath, size);
      } else {
        throw Exception('Download failed with status ${response.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('[DownloadManager] Failed to download ${track.id}: $e');
      rethrow; // Rethrow to let the UI show an error snackbar
    } finally {
      _downloading.remove(track.id);
    }
  }

  Future<void> deleteDownload(String trackId) async {
    final existing = await _library.getDownload(trackId);
    if (existing != null) {
      final file = File(existing.localPath);
      if (file.existsSync()) {
        await file.delete();
      }
      await _library.removeDownload(trackId);
    }
  }
}
