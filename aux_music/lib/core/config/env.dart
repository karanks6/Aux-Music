import 'dart:io';

/// Environment configuration for the Aux app.
abstract final class Env {
  /// The base URL for the Backend-for-Frontend (BFF).
  /// This must not have a trailing slash.
  static String get bffUrl {
    // We use 127.0.0.1 universally because:
    // 1. Windows Desktop natively uses 127.0.0.1
    // 2. Physical Android phones will hit 127.0.0.1 which is proxied to the PC via `adb reverse tcp:3000 tcp:3000`
    // This bypasses the Windows Firewall, which blocks local network IPs by default!
    return 'http://127.0.0.1:3000';
  }
}
