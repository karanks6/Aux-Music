import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/foundation.dart';

class PoTokenService {
  static final PoTokenService _instance = PoTokenService._internal();
  factory PoTokenService() => _instance;
  PoTokenService._internal();

  HeadlessInAppWebView? _headlessWebView;
  String? _poToken;
  String? _visitorData;
  Completer<void>? _initCompleter;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    if (_initCompleter != null) return _initCompleter!.future;
    
    _initCompleter = Completer<void>();

    try {
      _headlessWebView = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(url: WebUri("https://www.youtube.com/watch?v=aqz-KE-bpKQ")),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36",
          mediaPlaybackRequiresUserGesture: false,
          useShouldInterceptRequest: true,
        ),
        onWebViewCreated: (controller) {
          controller.addJavaScriptHandler(
            handlerName: "TokenHandler", 
            callback: (args) {
              final poToken = args[0] as String;
              final visitorData = args[1] as String;
              if (poToken.isNotEmpty && visitorData.isNotEmpty) {
                _poToken = poToken;
                _visitorData = visitorData;
                _isInitialized = true;
                debugPrint("PoToken Extracted: \$_poToken");
                if (!_initCompleter!.isCompleted) {
                  _initCompleter!.complete();
                }
              }
            }
          );
        },
        onLoadStart: (controller, url) async {
          // Inject fetch hook as early as possible
          await controller.evaluateJavascript(source: """
            if (!window.fetchHooked) {
              window.fetchHooked = true;
              const originalFetch = window.fetch;
              window.fetch = async function() {
                const url = arguments[0];
                const options = arguments[1];
                
                if (options && options.body && typeof options.body === 'string' && options.body.includes('poToken')) {
                  try {
                    const body = JSON.parse(options.body);
                    const poToken = body.serviceIntegrityDimensions?.poToken;
                    const visitorData = body.context?.client?.visitorData;
                    if (poToken && visitorData) {
                       window.flutter_inappwebview.callHandler('TokenHandler', poToken, visitorData);
                    }
                  } catch(e) {}
                }
                return originalFetch.apply(this, arguments);
              };
            }
          """);
        },
      );

      await _headlessWebView!.run();

      // Timeout fallback
      Future.delayed(const Duration(seconds: 15), () {
        if (!_initCompleter!.isCompleted) {
           debugPrint("PoToken extraction timed out. Falling back to empty.");
           _initCompleter!.complete(); // complete anyway to not block app
        }
      });
    } catch (e) {
      debugPrint("Error initializing PoTokenService: \$e");
      if (!_initCompleter!.isCompleted) {
        _initCompleter!.complete();
      }
    }

    return _initCompleter!.future;
  }

  String? get poToken => _poToken;
  String? get visitorData => _visitorData;
  
  void dispose() {
    _headlessWebView?.dispose();
    _headlessWebView = null;
  }
}
