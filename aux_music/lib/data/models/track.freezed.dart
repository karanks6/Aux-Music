// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Track _$TrackFromJson(Map<String, dynamic> json) {
  return _Track.fromJson(json);
}

/// @nodoc
mixin _$Track {
  /// Unique identifier within its source. Format: "{sourceId}:{nativeId}"
  String get id => throw _privateConstructorUsedError;

  /// Track title
  String get title => throw _privateConstructorUsedError;

  /// Primary artist display name
  String get artistName => throw _privateConstructorUsedError;

  /// Artist identifier (for navigation to artist page)
  String get artistId => throw _privateConstructorUsedError;

  /// Album name (may be empty for singles)
  String get albumName => throw _privateConstructorUsedError;

  /// Album identifier
  String get albumId => throw _privateConstructorUsedError;

  /// Album / single art URL (high-res preferred, ≥ 500px)
  String? get artworkUrl => throw _privateConstructorUsedError;

  /// Low-res thumbnail URL (≤ 150px) — used in mini-player and list tiles
  String? get thumbnailUrl => throw _privateConstructorUsedError;

  /// Which adapter served this track (e.g., 'audius', 'internet_archive')
  String get sourceId => throw _privateConstructorUsedError;

  /// License type — required; tracks with [LicenseType.unknown] are blocked from playback
  LicenseType get licenseType => throw _privateConstructorUsedError;

  /// Display-ready attribution (e.g., "Artist Name via Audius · CC BY")
  /// Must be non-empty for [licenseType] != [LicenseType.unknown]
  String get attributionString => throw _privateConstructorUsedError;

  /// Canonical link to the track's source page (for attribution)
  String get sourceUrl => throw _privateConstructorUsedError;

  /// ISO 639-1 or 639-3 language code (e.g., 'en', 'kn', 'tcy')
  String get language => throw _privateConstructorUsedError;

  /// Duration in milliseconds
  int get durationMs => throw _privateConstructorUsedError;

  /// Play count (from source where available)
  int get playCount => throw _privateConstructorUsedError;

  /// Whether this track can be downloaded for offline use
  /// Derived from [licenseType] but can be overridden by source adapter
  bool get offlineAllowed => throw _privateConstructorUsedError;

  /// Resolved stream URL — populated lazily just before playback
  String? get streamUrl => throw _privateConstructorUsedError;

  /// Genre tags (from source metadata or MusicBrainz enrichment)
  List<String> get genres => throw _privateConstructorUsedError;

  /// Additional tags / moods
  List<String> get tags => throw _privateConstructorUsedError;

  /// Whether the user has liked this track
  bool get isLiked => throw _privateConstructorUsedError;

  /// Whether this track is downloaded locally
  bool get isDownloaded => throw _privateConstructorUsedError;

  /// Local file path if downloaded
  String? get localPath => throw _privateConstructorUsedError;

  /// BPM (if available from source or MusicBrainz)
  double? get bpm => throw _privateConstructorUsedError;

  /// Waveform data points (normalized 0.0–1.0, up to 100 points)
  /// Used for the Now Playing waveform visualizer
  List<double> get waveformData => throw _privateConstructorUsedError;

  /// Timestamp when this track was added to the local library
  DateTime? get addedAt => throw _privateConstructorUsedError;

  /// Last played timestamp
  DateTime? get lastPlayedAt => throw _privateConstructorUsedError;

  /// Serializes this Track to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Track
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrackCopyWith<Track> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrackCopyWith<$Res> {
  factory $TrackCopyWith(Track value, $Res Function(Track) then) =
      _$TrackCopyWithImpl<$Res, Track>;
  @useResult
  $Res call(
      {String id,
      String title,
      String artistName,
      String artistId,
      String albumName,
      String albumId,
      String? artworkUrl,
      String? thumbnailUrl,
      String sourceId,
      LicenseType licenseType,
      String attributionString,
      String sourceUrl,
      String language,
      int durationMs,
      int playCount,
      bool offlineAllowed,
      String? streamUrl,
      List<String> genres,
      List<String> tags,
      bool isLiked,
      bool isDownloaded,
      String? localPath,
      double? bpm,
      List<double> waveformData,
      DateTime? addedAt,
      DateTime? lastPlayedAt});
}

/// @nodoc
class _$TrackCopyWithImpl<$Res, $Val extends Track>
    implements $TrackCopyWith<$Res> {
  _$TrackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Track
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? artistName = null,
    Object? artistId = null,
    Object? albumName = null,
    Object? albumId = null,
    Object? artworkUrl = freezed,
    Object? thumbnailUrl = freezed,
    Object? sourceId = null,
    Object? licenseType = null,
    Object? attributionString = null,
    Object? sourceUrl = null,
    Object? language = null,
    Object? durationMs = null,
    Object? playCount = null,
    Object? offlineAllowed = null,
    Object? streamUrl = freezed,
    Object? genres = null,
    Object? tags = null,
    Object? isLiked = null,
    Object? isDownloaded = null,
    Object? localPath = freezed,
    Object? bpm = freezed,
    Object? waveformData = null,
    Object? addedAt = freezed,
    Object? lastPlayedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artistName: null == artistName
          ? _value.artistName
          : artistName // ignore: cast_nullable_to_non_nullable
              as String,
      artistId: null == artistId
          ? _value.artistId
          : artistId // ignore: cast_nullable_to_non_nullable
              as String,
      albumName: null == albumName
          ? _value.albumName
          : albumName // ignore: cast_nullable_to_non_nullable
              as String,
      albumId: null == albumId
          ? _value.albumId
          : albumId // ignore: cast_nullable_to_non_nullable
              as String,
      artworkUrl: freezed == artworkUrl
          ? _value.artworkUrl
          : artworkUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceId: null == sourceId
          ? _value.sourceId
          : sourceId // ignore: cast_nullable_to_non_nullable
              as String,
      licenseType: null == licenseType
          ? _value.licenseType
          : licenseType // ignore: cast_nullable_to_non_nullable
              as LicenseType,
      attributionString: null == attributionString
          ? _value.attributionString
          : attributionString // ignore: cast_nullable_to_non_nullable
              as String,
      sourceUrl: null == sourceUrl
          ? _value.sourceUrl
          : sourceUrl // ignore: cast_nullable_to_non_nullable
              as String,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      durationMs: null == durationMs
          ? _value.durationMs
          : durationMs // ignore: cast_nullable_to_non_nullable
              as int,
      playCount: null == playCount
          ? _value.playCount
          : playCount // ignore: cast_nullable_to_non_nullable
              as int,
      offlineAllowed: null == offlineAllowed
          ? _value.offlineAllowed
          : offlineAllowed // ignore: cast_nullable_to_non_nullable
              as bool,
      streamUrl: freezed == streamUrl
          ? _value.streamUrl
          : streamUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      genres: null == genres
          ? _value.genres
          : genres // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      isDownloaded: null == isDownloaded
          ? _value.isDownloaded
          : isDownloaded // ignore: cast_nullable_to_non_nullable
              as bool,
      localPath: freezed == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String?,
      bpm: freezed == bpm
          ? _value.bpm
          : bpm // ignore: cast_nullable_to_non_nullable
              as double?,
      waveformData: null == waveformData
          ? _value.waveformData
          : waveformData // ignore: cast_nullable_to_non_nullable
              as List<double>,
      addedAt: freezed == addedAt
          ? _value.addedAt
          : addedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastPlayedAt: freezed == lastPlayedAt
          ? _value.lastPlayedAt
          : lastPlayedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrackImplCopyWith<$Res> implements $TrackCopyWith<$Res> {
  factory _$$TrackImplCopyWith(
          _$TrackImpl value, $Res Function(_$TrackImpl) then) =
      __$$TrackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String artistName,
      String artistId,
      String albumName,
      String albumId,
      String? artworkUrl,
      String? thumbnailUrl,
      String sourceId,
      LicenseType licenseType,
      String attributionString,
      String sourceUrl,
      String language,
      int durationMs,
      int playCount,
      bool offlineAllowed,
      String? streamUrl,
      List<String> genres,
      List<String> tags,
      bool isLiked,
      bool isDownloaded,
      String? localPath,
      double? bpm,
      List<double> waveformData,
      DateTime? addedAt,
      DateTime? lastPlayedAt});
}

/// @nodoc
class __$$TrackImplCopyWithImpl<$Res>
    extends _$TrackCopyWithImpl<$Res, _$TrackImpl>
    implements _$$TrackImplCopyWith<$Res> {
  __$$TrackImplCopyWithImpl(
      _$TrackImpl _value, $Res Function(_$TrackImpl) _then)
      : super(_value, _then);

  /// Create a copy of Track
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? artistName = null,
    Object? artistId = null,
    Object? albumName = null,
    Object? albumId = null,
    Object? artworkUrl = freezed,
    Object? thumbnailUrl = freezed,
    Object? sourceId = null,
    Object? licenseType = null,
    Object? attributionString = null,
    Object? sourceUrl = null,
    Object? language = null,
    Object? durationMs = null,
    Object? playCount = null,
    Object? offlineAllowed = null,
    Object? streamUrl = freezed,
    Object? genres = null,
    Object? tags = null,
    Object? isLiked = null,
    Object? isDownloaded = null,
    Object? localPath = freezed,
    Object? bpm = freezed,
    Object? waveformData = null,
    Object? addedAt = freezed,
    Object? lastPlayedAt = freezed,
  }) {
    return _then(_$TrackImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artistName: null == artistName
          ? _value.artistName
          : artistName // ignore: cast_nullable_to_non_nullable
              as String,
      artistId: null == artistId
          ? _value.artistId
          : artistId // ignore: cast_nullable_to_non_nullable
              as String,
      albumName: null == albumName
          ? _value.albumName
          : albumName // ignore: cast_nullable_to_non_nullable
              as String,
      albumId: null == albumId
          ? _value.albumId
          : albumId // ignore: cast_nullable_to_non_nullable
              as String,
      artworkUrl: freezed == artworkUrl
          ? _value.artworkUrl
          : artworkUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceId: null == sourceId
          ? _value.sourceId
          : sourceId // ignore: cast_nullable_to_non_nullable
              as String,
      licenseType: null == licenseType
          ? _value.licenseType
          : licenseType // ignore: cast_nullable_to_non_nullable
              as LicenseType,
      attributionString: null == attributionString
          ? _value.attributionString
          : attributionString // ignore: cast_nullable_to_non_nullable
              as String,
      sourceUrl: null == sourceUrl
          ? _value.sourceUrl
          : sourceUrl // ignore: cast_nullable_to_non_nullable
              as String,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      durationMs: null == durationMs
          ? _value.durationMs
          : durationMs // ignore: cast_nullable_to_non_nullable
              as int,
      playCount: null == playCount
          ? _value.playCount
          : playCount // ignore: cast_nullable_to_non_nullable
              as int,
      offlineAllowed: null == offlineAllowed
          ? _value.offlineAllowed
          : offlineAllowed // ignore: cast_nullable_to_non_nullable
              as bool,
      streamUrl: freezed == streamUrl
          ? _value.streamUrl
          : streamUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      genres: null == genres
          ? _value._genres
          : genres // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      isDownloaded: null == isDownloaded
          ? _value.isDownloaded
          : isDownloaded // ignore: cast_nullable_to_non_nullable
              as bool,
      localPath: freezed == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String?,
      bpm: freezed == bpm
          ? _value.bpm
          : bpm // ignore: cast_nullable_to_non_nullable
              as double?,
      waveformData: null == waveformData
          ? _value._waveformData
          : waveformData // ignore: cast_nullable_to_non_nullable
              as List<double>,
      addedAt: freezed == addedAt
          ? _value.addedAt
          : addedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastPlayedAt: freezed == lastPlayedAt
          ? _value.lastPlayedAt
          : lastPlayedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrackImpl extends _Track {
  const _$TrackImpl(
      {required this.id,
      required this.title,
      required this.artistName,
      this.artistId = '',
      this.albumName = '',
      this.albumId = '',
      this.artworkUrl,
      this.thumbnailUrl,
      required this.sourceId,
      this.licenseType = LicenseType.unknown,
      this.attributionString = '',
      this.sourceUrl = '',
      this.language = 'en',
      this.durationMs = 0,
      this.playCount = 0,
      this.offlineAllowed = true,
      this.streamUrl,
      final List<String> genres = const [],
      final List<String> tags = const [],
      this.isLiked = false,
      this.isDownloaded = false,
      this.localPath,
      this.bpm,
      final List<double> waveformData = const [],
      this.addedAt,
      this.lastPlayedAt})
      : _genres = genres,
        _tags = tags,
        _waveformData = waveformData,
        super._();

  factory _$TrackImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrackImplFromJson(json);

  /// Unique identifier within its source. Format: "{sourceId}:{nativeId}"
  @override
  final String id;

  /// Track title
  @override
  final String title;

  /// Primary artist display name
  @override
  final String artistName;

  /// Artist identifier (for navigation to artist page)
  @override
  @JsonKey()
  final String artistId;

  /// Album name (may be empty for singles)
  @override
  @JsonKey()
  final String albumName;

  /// Album identifier
  @override
  @JsonKey()
  final String albumId;

  /// Album / single art URL (high-res preferred, ≥ 500px)
  @override
  final String? artworkUrl;

  /// Low-res thumbnail URL (≤ 150px) — used in mini-player and list tiles
  @override
  final String? thumbnailUrl;

  /// Which adapter served this track (e.g., 'audius', 'internet_archive')
  @override
  final String sourceId;

  /// License type — required; tracks with [LicenseType.unknown] are blocked from playback
  @override
  @JsonKey()
  final LicenseType licenseType;

  /// Display-ready attribution (e.g., "Artist Name via Audius · CC BY")
  /// Must be non-empty for [licenseType] != [LicenseType.unknown]
  @override
  @JsonKey()
  final String attributionString;

  /// Canonical link to the track's source page (for attribution)
  @override
  @JsonKey()
  final String sourceUrl;

  /// ISO 639-1 or 639-3 language code (e.g., 'en', 'kn', 'tcy')
  @override
  @JsonKey()
  final String language;

  /// Duration in milliseconds
  @override
  @JsonKey()
  final int durationMs;

  /// Play count (from source where available)
  @override
  @JsonKey()
  final int playCount;

  /// Whether this track can be downloaded for offline use
  /// Derived from [licenseType] but can be overridden by source adapter
  @override
  @JsonKey()
  final bool offlineAllowed;

  /// Resolved stream URL — populated lazily just before playback
  @override
  final String? streamUrl;

  /// Genre tags (from source metadata or MusicBrainz enrichment)
  final List<String> _genres;

  /// Genre tags (from source metadata or MusicBrainz enrichment)
  @override
  @JsonKey()
  List<String> get genres {
    if (_genres is EqualUnmodifiableListView) return _genres;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_genres);
  }

  /// Additional tags / moods
  final List<String> _tags;

  /// Additional tags / moods
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  /// Whether the user has liked this track
  @override
  @JsonKey()
  final bool isLiked;

  /// Whether this track is downloaded locally
  @override
  @JsonKey()
  final bool isDownloaded;

  /// Local file path if downloaded
  @override
  final String? localPath;

  /// BPM (if available from source or MusicBrainz)
  @override
  final double? bpm;

  /// Waveform data points (normalized 0.0–1.0, up to 100 points)
  /// Used for the Now Playing waveform visualizer
  final List<double> _waveformData;

  /// Waveform data points (normalized 0.0–1.0, up to 100 points)
  /// Used for the Now Playing waveform visualizer
  @override
  @JsonKey()
  List<double> get waveformData {
    if (_waveformData is EqualUnmodifiableListView) return _waveformData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_waveformData);
  }

  /// Timestamp when this track was added to the local library
  @override
  final DateTime? addedAt;

  /// Last played timestamp
  @override
  final DateTime? lastPlayedAt;

  @override
  String toString() {
    return 'Track(id: $id, title: $title, artistName: $artistName, artistId: $artistId, albumName: $albumName, albumId: $albumId, artworkUrl: $artworkUrl, thumbnailUrl: $thumbnailUrl, sourceId: $sourceId, licenseType: $licenseType, attributionString: $attributionString, sourceUrl: $sourceUrl, language: $language, durationMs: $durationMs, playCount: $playCount, offlineAllowed: $offlineAllowed, streamUrl: $streamUrl, genres: $genres, tags: $tags, isLiked: $isLiked, isDownloaded: $isDownloaded, localPath: $localPath, bpm: $bpm, waveformData: $waveformData, addedAt: $addedAt, lastPlayedAt: $lastPlayedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artistName, artistName) ||
                other.artistName == artistName) &&
            (identical(other.artistId, artistId) ||
                other.artistId == artistId) &&
            (identical(other.albumName, albumName) ||
                other.albumName == albumName) &&
            (identical(other.albumId, albumId) || other.albumId == albumId) &&
            (identical(other.artworkUrl, artworkUrl) ||
                other.artworkUrl == artworkUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.sourceId, sourceId) ||
                other.sourceId == sourceId) &&
            (identical(other.licenseType, licenseType) ||
                other.licenseType == licenseType) &&
            (identical(other.attributionString, attributionString) ||
                other.attributionString == attributionString) &&
            (identical(other.sourceUrl, sourceUrl) ||
                other.sourceUrl == sourceUrl) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.durationMs, durationMs) ||
                other.durationMs == durationMs) &&
            (identical(other.playCount, playCount) ||
                other.playCount == playCount) &&
            (identical(other.offlineAllowed, offlineAllowed) ||
                other.offlineAllowed == offlineAllowed) &&
            (identical(other.streamUrl, streamUrl) ||
                other.streamUrl == streamUrl) &&
            const DeepCollectionEquality().equals(other._genres, _genres) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.isDownloaded, isDownloaded) ||
                other.isDownloaded == isDownloaded) &&
            (identical(other.localPath, localPath) ||
                other.localPath == localPath) &&
            (identical(other.bpm, bpm) || other.bpm == bpm) &&
            const DeepCollectionEquality()
                .equals(other._waveformData, _waveformData) &&
            (identical(other.addedAt, addedAt) || other.addedAt == addedAt) &&
            (identical(other.lastPlayedAt, lastPlayedAt) ||
                other.lastPlayedAt == lastPlayedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        artistName,
        artistId,
        albumName,
        albumId,
        artworkUrl,
        thumbnailUrl,
        sourceId,
        licenseType,
        attributionString,
        sourceUrl,
        language,
        durationMs,
        playCount,
        offlineAllowed,
        streamUrl,
        const DeepCollectionEquality().hash(_genres),
        const DeepCollectionEquality().hash(_tags),
        isLiked,
        isDownloaded,
        localPath,
        bpm,
        const DeepCollectionEquality().hash(_waveformData),
        addedAt,
        lastPlayedAt
      ]);

  /// Create a copy of Track
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrackImplCopyWith<_$TrackImpl> get copyWith =>
      __$$TrackImplCopyWithImpl<_$TrackImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrackImplToJson(
      this,
    );
  }
}

abstract class _Track extends Track {
  const factory _Track(
      {required final String id,
      required final String title,
      required final String artistName,
      final String artistId,
      final String albumName,
      final String albumId,
      final String? artworkUrl,
      final String? thumbnailUrl,
      required final String sourceId,
      final LicenseType licenseType,
      final String attributionString,
      final String sourceUrl,
      final String language,
      final int durationMs,
      final int playCount,
      final bool offlineAllowed,
      final String? streamUrl,
      final List<String> genres,
      final List<String> tags,
      final bool isLiked,
      final bool isDownloaded,
      final String? localPath,
      final double? bpm,
      final List<double> waveformData,
      final DateTime? addedAt,
      final DateTime? lastPlayedAt}) = _$TrackImpl;
  const _Track._() : super._();

  factory _Track.fromJson(Map<String, dynamic> json) = _$TrackImpl.fromJson;

  /// Unique identifier within its source. Format: "{sourceId}:{nativeId}"
  @override
  String get id;

  /// Track title
  @override
  String get title;

  /// Primary artist display name
  @override
  String get artistName;

  /// Artist identifier (for navigation to artist page)
  @override
  String get artistId;

  /// Album name (may be empty for singles)
  @override
  String get albumName;

  /// Album identifier
  @override
  String get albumId;

  /// Album / single art URL (high-res preferred, ≥ 500px)
  @override
  String? get artworkUrl;

  /// Low-res thumbnail URL (≤ 150px) — used in mini-player and list tiles
  @override
  String? get thumbnailUrl;

  /// Which adapter served this track (e.g., 'audius', 'internet_archive')
  @override
  String get sourceId;

  /// License type — required; tracks with [LicenseType.unknown] are blocked from playback
  @override
  LicenseType get licenseType;

  /// Display-ready attribution (e.g., "Artist Name via Audius · CC BY")
  /// Must be non-empty for [licenseType] != [LicenseType.unknown]
  @override
  String get attributionString;

  /// Canonical link to the track's source page (for attribution)
  @override
  String get sourceUrl;

  /// ISO 639-1 or 639-3 language code (e.g., 'en', 'kn', 'tcy')
  @override
  String get language;

  /// Duration in milliseconds
  @override
  int get durationMs;

  /// Play count (from source where available)
  @override
  int get playCount;

  /// Whether this track can be downloaded for offline use
  /// Derived from [licenseType] but can be overridden by source adapter
  @override
  bool get offlineAllowed;

  /// Resolved stream URL — populated lazily just before playback
  @override
  String? get streamUrl;

  /// Genre tags (from source metadata or MusicBrainz enrichment)
  @override
  List<String> get genres;

  /// Additional tags / moods
  @override
  List<String> get tags;

  /// Whether the user has liked this track
  @override
  bool get isLiked;

  /// Whether this track is downloaded locally
  @override
  bool get isDownloaded;

  /// Local file path if downloaded
  @override
  String? get localPath;

  /// BPM (if available from source or MusicBrainz)
  @override
  double? get bpm;

  /// Waveform data points (normalized 0.0–1.0, up to 100 points)
  /// Used for the Now Playing waveform visualizer
  @override
  List<double> get waveformData;

  /// Timestamp when this track was added to the local library
  @override
  DateTime? get addedAt;

  /// Last played timestamp
  @override
  DateTime? get lastPlayedAt;

  /// Create a copy of Track
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackImplCopyWith<_$TrackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
