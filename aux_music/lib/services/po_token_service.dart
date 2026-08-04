import 'dart:async';
import 'dart:collection';
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
        initialUrlRequest: URLRequest(url: WebUri("https://music.youtube.com/watch?v=aqz-KE-bpKQ")),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36",
          mediaPlaybackRequiresUserGesture: false, // Must be false so it autoplays and triggers token generation
          useShouldInterceptRequest: true,
        ),
        initialUserScripts: UnmodifiableListView<UserScript>([
          UserScript(
            source: """
              const originalPlay = HTMLMediaElement.prototype.play;
              HTMLMediaElement.prototype.play = function() {
                this.muted = true;
                this.volume = 0;
                return originalPlay.apply(this, arguments);
              };
            """,
            injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          )
        ]),
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
          // Inject fetch hook
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
                       document.querySelectorAll('video, audio').forEach(m => m.pause());
                    }
                  } catch(e) {}
                }
                return originalFetch.apply(this, arguments);
              };

              const originalXhrSend = XMLHttpRequest.prototype.send;
              XMLHttpRequest.prototype.send = function(body) {
                if (body && typeof body === 'string' && body.includes('poToken')) {
                  try {
                    const jsonBody = JSON.parse(body);
                    const poToken = jsonBody.serviceIntegrityDimensions?.poToken;
                    const visitorData = jsonBody.context?.client?.visitorData;
                    if (poToken && visitorData) {
                       window.flutter_inappwebview.callHandler('TokenHandler', poToken, visitorData);
                       document.querySelectorAll('video, audio').forEach(m => m.pause());
                    }
                  } catch(e) {}
                }
                return originalXhrSend.apply(this, arguments);
              };

              // Aggressively attempt to play the video to force BotGuard token generation
              setInterval(() => {
                document.querySelectorAll('video, audio').forEach(m => {
                  if (m.paused) {
                    m.play().catch(e => {
                        console.log("Play error: " + e.message);
                    });
                  }
                });
              }, 1000);
            }
          """);
        },
        onConsoleMessage: (controller, consoleMessage) {
          debugPrint("[WebView] \${consoleMessage.message}");
        },
      );

      await _headlessWebView!.run();

      // Timeout fallback
      Future.delayed(const Duration(seconds: 15), () {
        if (!_initCompleter!.isCompleted) {
           debugPrint("PoToken extraction timed out. Falling back to empty.");
           _initCompleter!.complete();
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
