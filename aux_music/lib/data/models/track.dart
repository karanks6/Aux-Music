import 'package:freezed_annotation/freezed_annotation.dart';
import 'license_type.dart';

part 'track.freezed.dart';
part 'track.g.dart';

/// The core Track model — every audio byte in Aux is represented by this.
///
/// Non-negotiable fields (from spec §2 + §3):
/// - [licenseType] — must never be null at playback time
/// - [attributionString] — must be visible within one tap of Now Playing
/// - [sourceId] — which adapter served this track
@freezed
abstract class Track with _$Track {
  const factory Track({
    /// Unique identifier within its source. Format: "{sourceId}:{nativeId}"
    required String id,

    /// Track title
    required String title,

    /// Primary artist display name
    required String artistName,

    /// Artist identifier (for navigation to artist page)
    @Default('') String artistId,

    /// Album name (may be empty for singles)
    @Default('') String albumName,

    /// Album identifier
    @Default('') String albumId,

    /// Album / single art URL (high-res preferred, ≥ 500px)
    String? artworkUrl,

    /// Low-res thumbnail URL (≤ 150px) — used in mini-player and list tiles
    String? thumbnailUrl,

    /// Which adapter served this track (e.g., 'audius', 'internet_archive')
    required String sourceId,

    /// License type — required; tracks with [LicenseType.unknown] are blocked from playback
    @Default(LicenseType.unknown) LicenseType licenseType,

    /// Display-ready attribution (e.g., "Artist Name via Audius · CC BY")
    /// Must be non-empty for [licenseType] != [LicenseType.unknown]
    @Default('') String attributionString,

    /// Canonical link to the track's source page (for attribution)
    @Default('') String sourceUrl,

    /// ISO 639-1 or 639-3 language code (e.g., 'en', 'kn', 'tcy')
    @Default('en') String language,

    /// Duration in milliseconds
    @Default(0) int durationMs,

    /// Play count (from source where available)
    @Default(0) int playCount,

    /// Whether this track can be downloaded for offline use
    /// Derived from [licenseType] but can be overridden by source adapter
    @Default(true) bool offlineAllowed,

    /// Resolved stream URL — populated lazily just before playback
    String? streamUrl,

    /// Genre tags (from source metadata or MusicBrainz enrichment)
    @Default([]) List<String> genres,

    /// Additional tags / moods
    @Default([]) List<String> tags,

    /// Whether the user has liked this track
    @Default(false) bool isLiked,

    /// Whether this track is downloaded locally
    @Default(false) bool isDownloaded,

    /// Local file path if downloaded
    String? localPath,

    /// BPM (if available from source or MusicBrainz)
    double? bpm,

    /// Waveform data points (normalized 0.0–1.0, up to 100 points)
    /// Used for the Now Playing waveform visualizer
    @Default([]) List<double> waveformData,

    /// Timestamp when this track was added to the local library
    DateTime? addedAt,

    /// Last played timestamp
    DateTime? lastPlayedAt,
  }) = _Track;

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

  const Track._();

  /// Whether this track has all required fields to play safely.
  bool get isPlayable =>
      licenseType != LicenseType.unknown &&
      attributionString.isNotEmpty &&
      title.isNotEmpty &&
      artistName.isNotEmpty;

  /// Display-safe duration string (e.g., "3:45")
  String get durationDisplay {
    if (durationMs <= 0) return '--:--';
    final total = durationMs ~/ 1000;
    final minutes = total ~/ 60;
    final seconds = total % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// The full attribution string to display in "About this Track" (one-tap from Now Playing)
  String get fullAttribution {
    final license = licenseType.displayLabel;
    if (attributionString.isNotEmpty) return attributionString;
    return '$artistName · $license';
  }
}
