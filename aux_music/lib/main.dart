import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/di/providers.dart';
import 'core/playback/playback_providers.dart';
import 'core/node_server/node_server_service.dart';
import 'features/splash/splash_screen.dart';
import 'services/audio_handler.dart';

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

  runApp(const Bootstrapper());
}

class Bootstrapper extends StatefulWidget {
  const Bootstrapper({super.key});

  @override
  State<Bootstrapper> createState() => _BootstrapperState();
}

class _BootstrapperState extends State<Bootstrapper> {
  bool _isReady = false;
  late final ProviderContainer _container;
  late final AuxAudioHandler _audioHandler;
  String _status = 'Starting up...';
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      if (mounted) setState(() => _status = 'Booting Node.js backend...');
      final nodeServer = NodeServerService();
      await nodeServer.start();

      if (mounted) setState(() => _status = 'Loading audio engine...');
      _container = ProviderContainer();
      _container.read(aggregatorInitProvider.future).catchError((_) {});
      _audioHandler = await initAudioHandler(_container);

      if (mounted) setState(() => _isReady = true);
    } catch (e, st) {
      if (mounted) {
        setState(() {
          _error = 'CRASH DURING INIT:\n$e\n$st';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ),
      );
    }

    if (!_isReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(status: _status),
      );
    }

    return ProviderScope(
      parent: _container,
      overrides: [
        audioHandlerProvider.overrideWithValue(_audioHandler),
      ],
      child: const AuxApp(),
    );
  }
}

