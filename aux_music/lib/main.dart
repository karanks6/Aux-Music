import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dio/dio.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/config/env.dart';
import 'core/di/providers.dart';
import 'core/playback/playback_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── System Chrome ────────────────────────────────────────────────
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Disabled edgeToEdge as it causes Gralloc failures on some MIUI devices.
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // ── Firebase ─────────────────────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── Riverpod container ───────────────────────────────────────────
  final container = ProviderContainer();

  // Trigger adapter initialization in the background (Audius node discovery, etc.)
  // We do NOT await this, to prevent blocking runApp and showing a black screen.
  container.read(aggregatorInitProvider.future).catchError((_) {});

  // ── Audio Service & RunApp ───────────────────────────────────────
  try {
    final handler = await initAudioHandler(container);

    // ── BFF Keep-alive ───────────────────────────────────────────────
    // Pings the Render free tier every 14 mins to prevent cold starts.
    _startBffKeepAlive();

    runApp(
      ProviderScope(
        overrides: [
          audioHandlerProvider.overrideWithValue(handler),
        ],
        child: const AuxApp(),
      ),
    );
  } catch (e, st) {
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Text(
                'CRASH DURING INIT:\n$e\n$st',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _startBffKeepAlive() {
  final dio = Dio();
  // Ping immediately
  dio.get('${Env.bffUrl}/health').catchError((_) => Response(requestOptions: RequestOptions()));
  // Then every 14 minutes (Render sleeps after 15 min inactivity)
  Stream.periodic(const Duration(minutes: 14)).listen((_) {
    dio.get('${Env.bffUrl}/health').catchError((_) => Response(requestOptions: RequestOptions()));
  });
}
