import 'package:freezed_annotation/freezed_annotation.dart';

/// All supported license types for audio tracks.
/// Used for license gating (offline, commercial use, etc.).
enum LicenseType {
  /// Creative Commons Zero — no rights reserved
  @JsonValue('CC0')
  cc0,

  /// Creative Commons Attribution
  @JsonValue('CC-BY')
  ccBy,

  /// Creative Commons Attribution-ShareAlike
  @JsonValue('CC-BY-SA')
  ccBySa,

  /// Creative Commons Attribution-NoDerivatives
  @JsonValue('CC-BY-ND')
  ccByNd,

  /// Creative Commons Attribution-NonCommercial
  @JsonValue('CC-BY-NC')
  ccByNc,

  /// Creative Commons Attribution-NonCommercial-ShareAlike
  @JsonValue('CC-BY-NC-SA')
  ccByNcSa,

  /// Creative Commons Attribution-NonCommercial-NoDerivatives
  @JsonValue('CC-BY-NC-ND')
  ccByNcNd,

  /// Public domain (pre-1928, Musopen, etc.)
  @JsonValue('PUBLIC_DOMAIN')
  publicDomain,

  /// Artist-declared custom license (community uploads)
  @JsonValue('CUSTOM')
  custom,

  /// Unknown — should never reach playback
  @JsonValue('UNKNOWN')
  unknown;

  /// Whether a track with this license can be downloaded for offline use.
  /// CC-NC licenses are still offline-allowed (download ≠ commercial use).
  bool get offlineAllowed => this != LicenseType.unknown;

  /// Human-readable short label for display in the UI.
  String get displayLabel {
    return switch (this) {
      LicenseType.cc0 => 'CC0',
      LicenseType.ccBy => 'CC BY',
      LicenseType.ccBySa => 'CC BY-SA',
      LicenseType.ccByNd => 'CC BY-ND',
      LicenseType.ccByNc => 'CC BY-NC',
      LicenseType.ccByNcSa => 'CC BY-NC-SA',
      LicenseType.ccByNcNd => 'CC BY-NC-ND',
      LicenseType.publicDomain => 'Public Domain',
      LicenseType.custom => 'Custom License',
      LicenseType.unknown => 'Unknown',
    };
  }

  /// Full Creative Commons URL for this license (or empty for PD/custom).
  String get licenseUrl {
    const base = 'https://creativecommons.org/licenses';
    return switch (this) {
      LicenseType.cc0 => 'https://creativecommons.org/publicdomain/zero/1.0/',
      LicenseType.ccBy => '$base/by/4.0/',
      LicenseType.ccBySa => '$base/by-sa/4.0/',
      LicenseType.ccByNd => '$base/by-nd/4.0/',
      LicenseType.ccByNc => '$base/by-nc/4.0/',
      LicenseType.ccByNcSa => '$base/by-nc-sa/4.0/',
      LicenseType.ccByNcNd => '$base/by-nc-nd/4.0/',
      LicenseType.publicDomain => 'https://creativecommons.org/publicdomain/mark/1.0/',
      _ => '',
    };
  }

  /// Parse from a license URL string (from Internet Archive, Jamendo, etc.)
  static LicenseType fromUrl(String? url) {
    if (url == null || url.isEmpty) return LicenseType.unknown;
    final u = url.toLowerCase();
    if (u.contains('zero') || u.contains('cc0')) return LicenseType.cc0;
    if (u.contains('by-nc-sa')) return LicenseType.ccByNcSa;
    if (u.contains('by-nc-nd')) return LicenseType.ccByNcNd;
    if (u.contains('by-nc')) return LicenseType.ccByNc;
    if (u.contains('by-sa')) return LicenseType.ccBySa;
    if (u.contains('by-nd')) return LicenseType.ccByNd;
    if (u.contains('by')) return LicenseType.ccBy;
    if (u.contains('publicdomain') || u.contains('public_domain') || u.contains('public-domain')) {
      return LicenseType.publicDomain;
    }
    return LicenseType.unknown;
  }
}
