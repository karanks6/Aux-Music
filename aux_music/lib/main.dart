import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/di/providers.dart';
import 'core/playback/playback_providers.dart';
import 'core/node_server/node_server_service.dart';
import 'services/po_token_service.dart';

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

  // ── Embedded Node.js BFF ─────────────────────────────────────────
  // Boots the local Fastify server inside the app process.
  // The server listens on 127.0.0.1:3000 — no external server needed.
  final nodeServer = NodeServerService();
  await nodeServer.start();

  // ── Riverpod container ───────────────────────────────────────────
  final container = ProviderContainer();

  // Trigger adapter initialization in the background
  container.read(aggregatorInitProvider.future).catchError((_) {});

  // Initialize PoTokenService to extract YouTube PoToken in the background
  PoTokenService().init().catchError((e) {
    debugPrint("PoTokenService initialization failed: \$e");
  });

  // ── Audio Service & RunApp ───────────────────────────────────────
  try {
    final handler = await initAudioHandler(container);

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

