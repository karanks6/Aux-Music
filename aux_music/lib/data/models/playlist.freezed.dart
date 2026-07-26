// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playlist.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlaylistCollaborator _$PlaylistCollaboratorFromJson(Map<String, dynamic> json) {
  return _PlaylistCollaborator.fromJson(json);
}

/// @nodoc
mixin _$PlaylistCollaborator {
  String get userId => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  PlaylistRole get role => throw _privateConstructorUsedError;

  /// Serializes this PlaylistCollaborator to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlaylistCollaborator
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaylistCollaboratorCopyWith<PlaylistCollaborator> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaylistCollaboratorCopyWith<$Res> {
  factory $PlaylistCollaboratorCopyWith(PlaylistCollaborator value,
          $Res Function(PlaylistCollaborator) then) =
      _$PlaylistCollaboratorCopyWithImpl<$Res, PlaylistCollaborator>;
  @useResult
  $Res call(
      {String userId,
      String displayName,
      String? avatarUrl,
      PlaylistRole role});
}

/// @nodoc
class _$PlaylistCollaboratorCopyWithImpl<$Res,
        $Val extends PlaylistCollaborator>
    implements $PlaylistCollaboratorCopyWith<$Res> {
  _$PlaylistCollaboratorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlaylistCollaborator
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? displayName = null,
    Object? avatarUrl = freezed,
    Object? role = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as PlaylistRole,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlaylistCollaboratorImplCopyWith<$Res>
    implements $PlaylistCollaboratorCopyWith<$Res> {
  factory _$$PlaylistCollaboratorImplCopyWith(_$PlaylistCollaboratorImpl value,
          $Res Function(_$PlaylistCollaboratorImpl) then) =
      __$$PlaylistCollaboratorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String displayName,
      String? avatarUrl,
      PlaylistRole role});
}

/// @nodoc
class __$$PlaylistCollaboratorImplCopyWithImpl<$Res>
    extends _$PlaylistCollaboratorCopyWithImpl<$Res, _$PlaylistCollaboratorImpl>
    implements _$$PlaylistCollaboratorImplCopyWith<$Res> {
  __$$PlaylistCollaboratorImplCopyWithImpl(_$PlaylistCollaboratorImpl _value,
      $Res Function(_$PlaylistCollaboratorImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlaylistCollaborator
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? displayName = null,
    Object? avatarUrl = freezed,
    Object? role = null,
  }) {
    return _then(_$PlaylistCollaboratorImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as PlaylistRole,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaylistCollaboratorImpl implements _PlaylistCollaborator {
  const _$PlaylistCollaboratorImpl(
      {required this.userId,
      required this.displayName,
      this.avatarUrl,
      this.role = PlaylistRole.viewOnly});

  factory _$PlaylistCollaboratorImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaylistCollaboratorImplFromJson(json);

  @override
  final String userId;
  @override
  final String displayName;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final PlaylistRole role;

  @override
  String toString() {
    return 'PlaylistCollaborator(userId: $userId, displayName: $displayName, avatarUrl: $avatarUrl, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaylistCollaboratorImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, displayName, avatarUrl, role);

  /// Create a copy of PlaylistCollaborator
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaylistCollaboratorImplCopyWith<_$PlaylistCollaboratorImpl>
      get copyWith =>
          __$$PlaylistCollaboratorImplCopyWithImpl<_$PlaylistCollaboratorImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaylistCollaboratorImplToJson(
      this,
    );
  }
}

abstract class _PlaylistCollaborator implements PlaylistCollaborator {
  const factory _PlaylistCollaborator(
      {required final String userId,
      required final String displayName,
      final String? avatarUrl,
      final PlaylistRole role}) = _$PlaylistCollaboratorImpl;

  factory _PlaylistCollaborator.fromJson(Map<String, dynamic> json) =
      _$PlaylistCollaboratorImpl.fromJson;

  @override
  String get userId;
  @override
  String get displayName;
  @override
  String? get avatarUrl;
  @override
  PlaylistRole get role;

  /// Create a copy of PlaylistCollaborator
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaylistCollaboratorImplCopyWith<_$PlaylistCollaboratorImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PlaylistActivity _$PlaylistActivityFromJson(Map<String, dynamic> json) {
  return _PlaylistActivity.fromJson(json);
}

/// @nodoc
mixin _$PlaylistActivity {
  String get userId => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String get action =>
      throw _privateConstructorUsedError; // 'added' | 'removed'
  String get trackTitle => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this PlaylistActivity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlaylistActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaylistActivityCopyWith<PlaylistActivity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaylistActivityCopyWith<$Res> {
  factory $PlaylistActivityCopyWith(
          PlaylistActivity value, $Res Function(PlaylistActivity) then) =
      _$PlaylistActivityCopyWithImpl<$Res, PlaylistActivity>;
  @useResult
  $Res call(
      {String userId,
      String displayName,
      String action,
      String trackTitle,
      DateTime timestamp});
}

/// @nodoc
class _$PlaylistActivityCopyWithImpl<$Res, $Val extends PlaylistActivity>
    implements $PlaylistActivityCopyWith<$Res> {
  _$PlaylistActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlaylistActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? displayName = null,
    Object? action = null,
    Object? trackTitle = null,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      trackTitle: null == trackTitle
          ? _value.trackTitle
          : trackTitle // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlaylistActivityImplCopyWith<$Res>
    implements $PlaylistActivityCopyWith<$Res> {
  factory _$$PlaylistActivityImplCopyWith(_$PlaylistActivityImpl value,
          $Res Function(_$PlaylistActivityImpl) then) =
      __$$PlaylistActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String displayName,
      String action,
      String trackTitle,
      DateTime timestamp});
}

/// @nodoc
class __$$PlaylistActivityImplCopyWithImpl<$Res>
    extends _$PlaylistActivityCopyWithImpl<$Res, _$PlaylistActivityImpl>
    implements _$$PlaylistActivityImplCopyWith<$Res> {
  __$$PlaylistActivityImplCopyWithImpl(_$PlaylistActivityImpl _value,
      $Res Function(_$PlaylistActivityImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlaylistActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? displayName = null,
    Object? action = null,
    Object? trackTitle = null,
    Object? timestamp = null,
  }) {
    return _then(_$PlaylistActivityImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      trackTitle: null == trackTitle
          ? _value.trackTitle
          : trackTitle // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaylistActivityImpl implements _PlaylistActivity {
  const _$PlaylistActivityImpl(
      {required this.userId,
      required this.displayName,
      required this.action,
      required this.trackTitle,
      required this.timestamp});

  factory _$PlaylistActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaylistActivityImplFromJson(json);

  @override
  final String userId;
  @override
  final String displayName;
  @override
  final String action;
// 'added' | 'removed'
  @override
  final String trackTitle;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'PlaylistActivity(userId: $userId, displayName: $displayName, action: $action, trackTitle: $trackTitle, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaylistActivityImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.trackTitle, trackTitle) ||
                other.trackTitle == trackTitle) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, userId, displayName, action, trackTitle, timestamp);

  /// Create a copy of PlaylistActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaylistActivityImplCopyWith<_$PlaylistActivityImpl> get copyWith =>
      __$$PlaylistActivityImplCopyWithImpl<_$PlaylistActivityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaylistActivityImplToJson(
      this,
    );
  }
}

abstract class _PlaylistActivity implements PlaylistActivity {
  const factory _PlaylistActivity(
      {required final String userId,
      required final String displayName,
      required final String action,
      required final String trackTitle,
      required final DateTime timestamp}) = _$PlaylistActivityImpl;

  factory _PlaylistActivity.fromJson(Map<String, dynamic> json) =
      _$PlaylistActivityImpl.fromJson;

  @override
  String get userId;
  @override
  String get displayName;
  @override
  String get action; // 'added' | 'removed'
  @override
  String get trackTitle;
  @override
  DateTime get timestamp;

  /// Create a copy of PlaylistActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaylistActivityImplCopyWith<_$PlaylistActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Playlist _$PlaylistFromJson(Map<String, dynamic> json) {
  return _Playlist.fromJson(json);
}

/// @nodoc
mixin _$Playlist {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError;
  String? get ownerName => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Custom cover art URL, or null if using auto-generated mosaic
  String? get coverArtUrl => throw _privateConstructorUsedError;

  /// The 4 track artwork URLs used for the mosaic (auto-generated)
  List<String> get mosaicArts => throw _privateConstructorUsedError;
  List<Track> get tracks => throw _privateConstructorUsedError;
  int get trackCount => throw _privateConstructorUsedError;

  /// Collaborators (empty for solo playlists)
  List<PlaylistCollaborator> get collaborators =>
      throw _privateConstructorUsedError;

  /// Activity feed — who added/removed what
  List<PlaylistActivity> get activityFeed => throw _privateConstructorUsedError;
  bool get isCollaborative => throw _privateConstructorUsedError;
  bool get isPublic => throw _privateConstructorUsedError;

  /// Firestore document ID (null for local-only playlists)
  String? get firestoreId => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get lastPlayedAt => throw _privateConstructorUsedError;

  /// Serializes this Playlist to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Playlist
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaylistCopyWith<Playlist> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaylistCopyWith<$Res> {
  factory $PlaylistCopyWith(Playlist value, $Res Function(Playlist) then) =
      _$PlaylistCopyWithImpl<$Res, Playlist>;
  @useResult
  $Res call(
      {String id,
      String name,
      String ownerId,
      String? ownerName,
      String? description,
      String? coverArtUrl,
      List<String> mosaicArts,
      List<Track> tracks,
      int trackCount,
      List<PlaylistCollaborator> collaborators,
      List<PlaylistActivity> activityFeed,
      bool isCollaborative,
      bool isPublic,
      String? firestoreId,
      DateTime? createdAt,
      DateTime? updatedAt,
      DateTime? lastPlayedAt});
}

/// @nodoc
class _$PlaylistCopyWithImpl<$Res, $Val extends Playlist>
    implements $PlaylistCopyWith<$Res> {
  _$PlaylistCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Playlist
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ownerId = null,
    Object? ownerName = freezed,
    Object? description = freezed,
    Object? coverArtUrl = freezed,
    Object? mosaicArts = null,
    Object? tracks = null,
    Object? trackCount = null,
    Object? collaborators = null,
    Object? activityFeed = null,
    Object? isCollaborative = null,
    Object? isPublic = null,
    Object? firestoreId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? lastPlayedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      ownerName: freezed == ownerName
          ? _value.ownerName
          : ownerName // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      coverArtUrl: freezed == coverArtUrl
          ? _value.coverArtUrl
          : coverArtUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      mosaicArts: null == mosaicArts
          ? _value.mosaicArts
          : mosaicArts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tracks: null == tracks
          ? _value.tracks
          : tracks // ignore: cast_nullable_to_non_nullable
              as List<Track>,
      trackCount: null == trackCount
          ? _value.trackCount
          : trackCount // ignore: cast_nullable_to_non_nullable
              as int,
      collaborators: null == collaborators
          ? _value.collaborators
          : collaborators // ignore: cast_nullable_to_non_nullable
              as List<PlaylistCollaborator>,
      activityFeed: null == activityFeed
          ? _value.activityFeed
          : activityFeed // ignore: cast_nullable_to_non_nullable
              as List<PlaylistActivity>,
      isCollaborative: null == isCollaborative
          ? _value.isCollaborative
          : isCollaborative // ignore: cast_nullable_to_non_nullable
              as bool,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      firestoreId: freezed == firestoreId
          ? _value.firestoreId
          : firestoreId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastPlayedAt: freezed == lastPlayedAt
          ? _value.lastPlayedAt
          : lastPlayedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlaylistImplCopyWith<$Res>
    implements $PlaylistCopyWith<$Res> {
  factory _$$PlaylistImplCopyWith(
          _$PlaylistImpl value, $Res Function(_$PlaylistImpl) then) =
      __$$PlaylistImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String ownerId,
      String? ownerName,
      String? description,
      String? coverArtUrl,
      List<String> mosaicArts,
      List<Track> tracks,
      int trackCount,
      List<PlaylistCollaborator> collaborators,
      List<PlaylistActivity> activityFeed,
      bool isCollaborative,
      bool isPublic,
      String? firestoreId,
      DateTime? createdAt,
      DateTime? updatedAt,
      DateTime? lastPlayedAt});
}

/// @nodoc
class __$$PlaylistImplCopyWithImpl<$Res>
    extends _$PlaylistCopyWithImpl<$Res, _$PlaylistImpl>
    implements _$$PlaylistImplCopyWith<$Res> {
  __$$PlaylistImplCopyWithImpl(
      _$PlaylistImpl _value, $Res Function(_$PlaylistImpl) _then)
      : super(_value, _then);

  /// Create a copy of Playlist
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ownerId = null,
    Object? ownerName = freezed,
    Object? description = freezed,
    Object? coverArtUrl = freezed,
    Object? mosaicArts = null,
    Object? tracks = null,
    Object? trackCount = null,
    Object? collaborators = null,
    Object? activityFeed = null,
    Object? isCollaborative = null,
    Object? isPublic = null,
    Object? firestoreId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? lastPlayedAt = freezed,
  }) {
    return _then(_$PlaylistImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      ownerName: freezed == ownerName
          ? _value.ownerName
          : ownerName // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      coverArtUrl: freezed == coverArtUrl
          ? _value.coverArtUrl
          : coverArtUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      mosaicArts: null == mosaicArts
          ? _value._mosaicArts
          : mosaicArts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tracks: null == tracks
          ? _value._tracks
          : tracks // ignore: cast_nullable_to_non_nullable
              as List<Track>,
      trackCount: null == trackCount
          ? _value.trackCount
          : trackCount // ignore: cast_nullable_to_non_nullable
              as int,
      collaborators: null == collaborators
          ? _value._collaborators
          : collaborators // ignore: cast_nullable_to_non_nullable
              as List<PlaylistCollaborator>,
      activityFeed: null == activityFeed
          ? _value._activityFeed
          : activityFeed // ignore: cast_nullable_to_non_nullable
              as List<PlaylistActivity>,
      isCollaborative: null == isCollaborative
          ? _value.isCollaborative
          : isCollaborative // ignore: cast_nullable_to_non_nullable
              as bool,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      firestoreId: freezed == firestoreId
          ? _value.firestoreId
          : firestoreId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
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
class _$PlaylistImpl implements _Playlist {
  const _$PlaylistImpl(
      {required this.id,
      required this.name,
      required this.ownerId,
      this.ownerName,
      this.description,
      this.coverArtUrl,
      final List<String> mosaicArts = const [],
      final List<Track> tracks = const [],
      this.trackCount = 0,
      final List<PlaylistCollaborator> collaborators = const [],
      final List<PlaylistActivity> activityFeed = const [],
      this.isCollaborative = false,
      this.isPublic = false,
      this.firestoreId,
      this.createdAt,
      this.updatedAt,
      this.lastPlayedAt})
      : _mosaicArts = mosaicArts,
        _tracks = tracks,
        _collaborators = collaborators,
        _activityFeed = activityFeed;

  factory _$PlaylistImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaylistImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String ownerId;
  @override
  final String? ownerName;
  @override
  final String? description;

  /// Custom cover art URL, or null if using auto-generated mosaic
  @override
  final String? coverArtUrl;

  /// The 4 track artwork URLs used for the mosaic (auto-generated)
  final List<String> _mosaicArts;

  /// The 4 track artwork URLs used for the mosaic (auto-generated)
  @override
  @JsonKey()
  List<String> get mosaicArts {
    if (_mosaicArts is EqualUnmodifiableListView) return _mosaicArts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mosaicArts);
  }

  final List<Track> _tracks;
  @override
  @JsonKey()
  List<Track> get tracks {
    if (_tracks is EqualUnmodifiableListView) return _tracks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tracks);
  }

  @override
  @JsonKey()
  final int trackCount;

  /// Collaborators (empty for solo playlists)
  final List<PlaylistCollaborator> _collaborators;

  /// Collaborators (empty for solo playlists)
  @override
  @JsonKey()
  List<PlaylistCollaborator> get collaborators {
    if (_collaborators is EqualUnmodifiableListView) return _collaborators;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_collaborators);
  }

  /// Activity feed — who added/removed what
  final List<PlaylistActivity> _activityFeed;

  /// Activity feed — who added/removed what
  @override
  @JsonKey()
  List<PlaylistActivity> get activityFeed {
    if (_activityFeed is EqualUnmodifiableListView) return _activityFeed;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activityFeed);
  }

  @override
  @JsonKey()
  final bool isCollaborative;
  @override
  @JsonKey()
  final bool isPublic;

  /// Firestore document ID (null for local-only playlists)
  @override
  final String? firestoreId;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? lastPlayedAt;

  @override
  String toString() {
    return 'Playlist(id: $id, name: $name, ownerId: $ownerId, ownerName: $ownerName, description: $description, coverArtUrl: $coverArtUrl, mosaicArts: $mosaicArts, tracks: $tracks, trackCount: $trackCount, collaborators: $collaborators, activityFeed: $activityFeed, isCollaborative: $isCollaborative, isPublic: $isPublic, firestoreId: $firestoreId, createdAt: $createdAt, updatedAt: $updatedAt, lastPlayedAt: $lastPlayedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaylistImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.ownerName, ownerName) ||
                other.ownerName == ownerName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.coverArtUrl, coverArtUrl) ||
                other.coverArtUrl == coverArtUrl) &&
            const DeepCollectionEquality()
                .equals(other._mosaicArts, _mosaicArts) &&
            const DeepCollectionEquality().equals(other._tracks, _tracks) &&
            (identical(other.trackCount, trackCount) ||
                other.trackCount == trackCount) &&
            const DeepCollectionEquality()
                .equals(other._collaborators, _collaborators) &&
            const DeepCollectionEquality()
                .equals(other._activityFeed, _activityFeed) &&
            (identical(other.isCollaborative, isCollaborative) ||
                other.isCollaborative == isCollaborative) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.firestoreId, firestoreId) ||
                other.firestoreId == firestoreId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastPlayedAt, lastPlayedAt) ||
                other.lastPlayedAt == lastPlayedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      ownerId,
      ownerName,
      description,
      coverArtUrl,
      const DeepCollectionEquality().hash(_mosaicArts),
      const DeepCollectionEquality().hash(_tracks),
      trackCount,
      const DeepCollectionEquality().hash(_collaborators),
      const DeepCollectionEquality().hash(_activityFeed),
      isCollaborative,
      isPublic,
      firestoreId,
      createdAt,
      updatedAt,
      lastPlayedAt);

  /// Create a copy of Playlist
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaylistImplCopyWith<_$PlaylistImpl> get copyWith =>
      __$$PlaylistImplCopyWithImpl<_$PlaylistImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaylistImplToJson(
      this,
    );
  }
}

abstract class _Playlist implements Playlist {
  const factory _Playlist(
      {required final String id,
      required final String name,
      required final String ownerId,
      final String? ownerName,
      final String? description,
      final String? coverArtUrl,
      final List<String> mosaicArts,
      final List<Track> tracks,
      final int trackCount,
      final List<PlaylistCollaborator> collaborators,
      final List<PlaylistActivity> activityFeed,
      final bool isCollaborative,
      final bool isPublic,
      final String? firestoreId,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final DateTime? lastPlayedAt}) = _$PlaylistImpl;

  factory _Playlist.fromJson(Map<String, dynamic> json) =
      _$PlaylistImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get ownerId;
  @override
  String? get ownerName;
  @override
  String? get description;

  /// Custom cover art URL, or null if using auto-generated mosaic
  @override
  String? get coverArtUrl;

  /// The 4 track artwork URLs used for the mosaic (auto-generated)
  @override
  List<String> get mosaicArts;
  @override
  List<Track> get tracks;
  @override
  int get trackCount;

  /// Collaborators (empty for solo playlists)
  @override
  List<PlaylistCollaborator> get collaborators;

  /// Activity feed — who added/removed what
  @override
  List<PlaylistActivity> get activityFeed;
  @override
  bool get isCollaborative;
  @override
  bool get isPublic;

  /// Firestore document ID (null for local-only playlists)
  @override
  String? get firestoreId;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get lastPlayedAt;

  /// Create a copy of Playlist
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaylistImplCopyWith<_$PlaylistImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
