/// Environment configuration for the Aux app.
/// Replace `bffUrl` with your actual Render deployment URL.
abstract final class Env {
  /// The base URL for the Backend-for-Frontend (BFF).
  /// This must not have a trailing slash.
  static const String bffUrl = 'https://aux-music-bff.onrender.com';
}
