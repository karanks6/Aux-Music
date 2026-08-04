import 'dart:io';

/// Environment configuration for the Aux app.
abstract final class Env {
  /// The base URL for the Backend-for-Frontend (BFF).
  /// This must not have a trailing slash.
  static String get bffUrl {
    return 'http://127.0.0.1:3000';
  }
}
