import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:node_flutter/node_flutter.dart';

/// Manages the lifecycle of the embedded Node.js BFF server.
///
/// - Starts the Node server when the app launches
/// - Shuts it down when the app pauses/backgrounds
/// - Restarts it when the app resumes
/// - Polls /health until ready before letting UI render
class NodeServerService with WidgetsBindingObserver {
  static const int _port = 3000;
  static const String _baseUrl = 'http://127.0.0.1:$_port';
  static const int _maxHealthRetries = 20;
  static const Duration _healthRetryDelay = Duration(milliseconds: 500);

  bool _isRunning = false;

  /// Starts the embedded Node.js server and waits for it to be ready.
  /// Call this from main() before runApp().
  Future<void> start() async {
    WidgetsBinding.instance.addObserver(this);
    await _startServer();
  }

  Future<void> _startServer() async {
    if (_isRunning) return;
    debugPrint('[NodeServer] Starting embedded Node.js server...');
    try {
      // node_flutter looks for the entry file inside:
      // android/app/src/main/assets/nodejs-project/
      await Nodejs.start(fileName: 'src/index.js');
      _isRunning = true;
      debugPrint('[NodeServer] Node.js runtime started. Waiting for server...');
      await _waitForHealth();
      debugPrint('[NodeServer] Server ready at $_baseUrl');
    } catch (e) {
      debugPrint('[NodeServer] Failed to start: $e');
    }
  }

  Future<void> _stopServer() async {
    if (!_isRunning) return;
    debugPrint('[NodeServer] Stopping Node.js server...');
    // node_flutter does not expose a stop API directly; we send a shutdown signal
    Nodejs.sendMessage('lifecycle', 'STOP');
    _isRunning = false;
  }

  /// Polls GET /health until the server responds OK, up to [_maxHealthRetries] times.
  Future<void> _waitForHealth() async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 2);

    for (int i = 0; i < _maxHealthRetries; i++) {
      try {
        final req = await client.getUrl(Uri.parse('$_baseUrl/health'));
        final res = await req.close();
        if (res.statusCode == 200) {
          client.close();
          return;
        }
      } catch (_) {
        // Server not yet ready
      }
      await Future.delayed(_healthRetryDelay);
    }

    client.close();
    debugPrint('[NodeServer] Warning: server did not become healthy in time. Proceeding anyway.');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _stopServer();
        break;
      case AppLifecycleState.resumed:
        _startServer();
        break;
      default:
        break;
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopServer();
  }
}
