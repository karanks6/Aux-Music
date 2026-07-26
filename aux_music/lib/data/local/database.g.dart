// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $LikedTracksTable extends LikedTracks
    with TableInfo<$LikedTracksTable, LikedTrack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LikedTracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _artistNameMeta =
      const VerificationMeta('artistName');
  @override
  late final GeneratedColumn<String> artistName = GeneratedColumn<String>(
      'artist_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _artistIdMeta =
      const VerificationMeta('artistId');
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
      'artist_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _albumNameMeta =
      const VerificationMeta('albumName');
  @override
  late final GeneratedColumn<String> albumName = GeneratedColumn<String>(
      'album_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _albumIdMeta =
      const VerificationMeta('albumId');
  @override
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
      'album_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _artworkUrlMeta =
      const VerificationMeta('artworkUrl');
  @override
  late final GeneratedColumn<String> artworkUrl = GeneratedColumn<String>(
      'artwork_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailUrlMeta =
      const VerificationMeta('thumbnailUrl');
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
      'thumbnail_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _licenseTypeMeta =
      const VerificationMeta('licenseType');
  @override
  late final GeneratedColumn<String> licenseType = GeneratedColumn<String>(
      'license_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _attributionStringMeta =
      const VerificationMeta('attributionString');
  @override
  late final GeneratedColumn<String> attributionString =
      GeneratedColumn<String>('attribution_string', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceUrlMeta =
      const VerificationMeta('sourceUrl');
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
      'source_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _playCountMeta =
      const VerificationMeta('playCount');
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
      'play_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _offlineAllowedMeta =
      const VerificationMeta('offlineAllowed');
  @override
  late final GeneratedColumn<bool> offlineAllowed = GeneratedColumn<bool>(
      'offline_allowed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("offline_allowed" IN (0, 1))'));
  static const VerificationMeta _likedAtMeta =
      const VerificationMeta('likedAt');
  @override
  late final GeneratedColumn<DateTime> likedAt = GeneratedColumn<DateTime>(
      'liked_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
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
        likedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'liked_tracks';
  @override
  VerificationContext validateIntegrity(Insertable<LikedTrack> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist_name')) {
      context.handle(
          _artistNameMeta,
          artistName.isAcceptableOrUnknown(
              data['artist_name']!, _artistNameMeta));
    } else if (isInserting) {
      context.missing(_artistNameMeta);
    }
    if (data.containsKey('artist_id')) {
      context.handle(_artistIdMeta,
          artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta));
    } else if (isInserting) {
      context.missing(_artistIdMeta);
    }
    if (data.containsKey('album_name')) {
      context.handle(_albumNameMeta,
          albumName.isAcceptableOrUnknown(data['album_name']!, _albumNameMeta));
    } else if (isInserting) {
      context.missing(_albumNameMeta);
    }
    if (data.containsKey('album_id')) {
      context.handle(_albumIdMeta,
          albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta));
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    if (data.containsKey('artwork_url')) {
      context.handle(
          _artworkUrlMeta,
          artworkUrl.isAcceptableOrUnknown(
              data['artwork_url']!, _artworkUrlMeta));
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
          _thumbnailUrlMeta,
          thumbnailUrl.isAcceptableOrUnknown(
              data['thumbnail_url']!, _thumbnailUrlMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('license_type')) {
      context.handle(
          _licenseTypeMeta,
          licenseType.isAcceptableOrUnknown(
              data['license_type']!, _licenseTypeMeta));
    } else if (isInserting) {
      context.missing(_licenseTypeMeta);
    }
    if (data.containsKey('attribution_string')) {
      context.handle(
          _attributionStringMeta,
          attributionString.isAcceptableOrUnknown(
              data['attribution_string']!, _attributionStringMeta));
    } else if (isInserting) {
      context.missing(_attributionStringMeta);
    }
    if (data.containsKey('source_url')) {
      context.handle(_sourceUrlMeta,
          sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta));
    } else if (isInserting) {
      context.missing(_sourceUrlMeta);
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('play_count')) {
      context.handle(_playCountMeta,
          playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta));
    } else if (isInserting) {
      context.missing(_playCountMeta);
    }
    if (data.containsKey('offline_allowed')) {
      context.handle(
          _offlineAllowedMeta,
          offlineAllowed.isAcceptableOrUnknown(
              data['offline_allowed']!, _offlineAllowedMeta));
    } else if (isInserting) {
      context.missing(_offlineAllowedMeta);
    }
    if (data.containsKey('liked_at')) {
      context.handle(_likedAtMeta,
          likedAt.isAcceptableOrUnknown(data['liked_at']!, _likedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LikedTrack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LikedTrack(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      artistName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artist_name'])!,
      artistId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artist_id'])!,
      albumName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}album_name'])!,
      albumId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}album_id'])!,
      artworkUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artwork_url']),
      thumbnailUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_url']),
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      licenseType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}license_type'])!,
      attributionString: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}attribution_string'])!,
      sourceUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_url'])!,
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms'])!,
      playCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}play_count'])!,
      offlineAllowed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}offline_allowed'])!,
      likedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}liked_at'])!,
    );
  }

  @override
  $LikedTracksTable createAlias(String alias) {
    return $LikedTracksTable(attachedDatabase, alias);
  }
}

class LikedTrack extends DataClass implements Insertable<LikedTrack> {
  final String id;
  final String title;
  final String artistName;
  final String artistId;
  final String albumName;
  final String albumId;
  final String? artworkUrl;
  final String? thumbnailUrl;
  final String sourceId;
  final String licenseType;
  final String attributionString;
  final String sourceUrl;
  final String language;
  final int durationMs;
  final int playCount;
  final bool offlineAllowed;
  final DateTime likedAt;
  const LikedTrack(
      {required this.id,
      required this.title,
      required this.artistName,
      required this.artistId,
      required this.albumName,
      required this.albumId,
      this.artworkUrl,
      this.thumbnailUrl,
      required this.sourceId,
      required this.licenseType,
      required this.attributionString,
      required this.sourceUrl,
      required this.language,
      required this.durationMs,
      required this.playCount,
      required this.offlineAllowed,
      required this.likedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['artist_name'] = Variable<String>(artistName);
    map['artist_id'] = Variable<String>(artistId);
    map['album_name'] = Variable<String>(albumName);
    map['album_id'] = Variable<String>(albumId);
    if (!nullToAbsent || artworkUrl != null) {
      map['artwork_url'] = Variable<String>(artworkUrl);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    map['source_id'] = Variable<String>(sourceId);
    map['license_type'] = Variable<String>(licenseType);
    map['attribution_string'] = Variable<String>(attributionString);
    map['source_url'] = Variable<String>(sourceUrl);
    map['language'] = Variable<String>(language);
    map['duration_ms'] = Variable<int>(durationMs);
    map['play_count'] = Variable<int>(playCount);
    map['offline_allowed'] = Variable<bool>(offlineAllowed);
    map['liked_at'] = Variable<DateTime>(likedAt);
    return map;
  }

  LikedTracksCompanion toCompanion(bool nullToAbsent) {
    return LikedTracksCompanion(
      id: Value(id),
      title: Value(title),
      artistName: Value(artistName),
      artistId: Value(artistId),
      albumName: Value(albumName),
      albumId: Value(albumId),
      artworkUrl: artworkUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkUrl),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      sourceId: Value(sourceId),
      licenseType: Value(licenseType),
      attributionString: Value(attributionString),
      sourceUrl: Value(sourceUrl),
      language: Value(language),
      durationMs: Value(durationMs),
      playCount: Value(playCount),
      offlineAllowed: Value(offlineAllowed),
      likedAt: Value(likedAt),
    );
  }

  factory LikedTrack.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LikedTrack(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      artistName: serializer.fromJson<String>(json['artistName']),
      artistId: serializer.fromJson<String>(json['artistId']),
      albumName: serializer.fromJson<String>(json['albumName']),
      albumId: serializer.fromJson<String>(json['albumId']),
      artworkUrl: serializer.fromJson<String?>(json['artworkUrl']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      licenseType: serializer.fromJson<String>(json['licenseType']),
      attributionString: serializer.fromJson<String>(json['attributionString']),
      sourceUrl: serializer.fromJson<String>(json['sourceUrl']),
      language: serializer.fromJson<String>(json['language']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      playCount: serializer.fromJson<int>(json['playCount']),
      offlineAllowed: serializer.fromJson<bool>(json['offlineAllowed']),
      likedAt: serializer.fromJson<DateTime>(json['likedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'artistName': serializer.toJson<String>(artistName),
      'artistId': serializer.toJson<String>(artistId),
      'albumName': serializer.toJson<String>(albumName),
      'albumId': serializer.toJson<String>(albumId),
      'artworkUrl': serializer.toJson<String?>(artworkUrl),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'sourceId': serializer.toJson<String>(sourceId),
      'licenseType': serializer.toJson<String>(licenseType),
      'attributionString': serializer.toJson<String>(attributionString),
      'sourceUrl': serializer.toJson<String>(sourceUrl),
      'language': serializer.toJson<String>(language),
      'durationMs': serializer.toJson<int>(durationMs),
      'playCount': serializer.toJson<int>(playCount),
      'offlineAllowed': serializer.toJson<bool>(offlineAllowed),
      'likedAt': serializer.toJson<DateTime>(likedAt),
    };
  }

  LikedTrack copyWith(
          {String? id,
          String? title,
          String? artistName,
          String? artistId,
          String? albumName,
          String? albumId,
          Value<String?> artworkUrl = const Value.absent(),
          Value<String?> thumbnailUrl = const Value.absent(),
          String? sourceId,
          String? licenseType,
          String? attributionString,
          String? sourceUrl,
          String? language,
          int? durationMs,
          int? playCount,
          bool? offlineAllowed,
          DateTime? likedAt}) =>
      LikedTrack(
        id: id ?? this.id,
        title: title ?? this.title,
        artistName: artistName ?? this.artistName,
        artistId: artistId ?? this.artistId,
        albumName: albumName ?? this.albumName,
        albumId: albumId ?? this.albumId,
        artworkUrl: artworkUrl.present ? artworkUrl.value : this.artworkUrl,
        thumbnailUrl:
            thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
        sourceId: sourceId ?? this.sourceId,
        licenseType: licenseType ?? this.licenseType,
        attributionString: attributionString ?? this.attributionString,
        sourceUrl: sourceUrl ?? this.sourceUrl,
        language: language ?? this.language,
        durationMs: durationMs ?? this.durationMs,
        playCount: playCount ?? this.playCount,
        offlineAllowed: offlineAllowed ?? this.offlineAllowed,
        likedAt: likedAt ?? this.likedAt,
      );
  LikedTrack copyWithCompanion(LikedTracksCompanion data) {
    return LikedTrack(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      artistName:
          data.artistName.present ? data.artistName.value : this.artistName,
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
      albumName: data.albumName.present ? data.albumName.value : this.albumName,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      artworkUrl:
          data.artworkUrl.present ? data.artworkUrl.value : this.artworkUrl,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      licenseType:
          data.licenseType.present ? data.licenseType.value : this.licenseType,
      attributionString: data.attributionString.present
          ? data.attributionString.value
          : this.attributionString,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      language: data.language.present ? data.language.value : this.language,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      offlineAllowed: data.offlineAllowed.present
          ? data.offlineAllowed.value
          : this.offlineAllowed,
      likedAt: data.likedAt.present ? data.likedAt.value : this.likedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LikedTrack(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artistName: $artistName, ')
          ..write('artistId: $artistId, ')
          ..write('albumName: $albumName, ')
          ..write('albumId: $albumId, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('sourceId: $sourceId, ')
          ..write('licenseType: $licenseType, ')
          ..write('attributionString: $attributionString, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('language: $language, ')
          ..write('durationMs: $durationMs, ')
          ..write('playCount: $playCount, ')
          ..write('offlineAllowed: $offlineAllowed, ')
          ..write('likedAt: $likedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
      likedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LikedTrack &&
          other.id == this.id &&
          other.title == this.title &&
          other.artistName == this.artistName &&
          other.artistId == this.artistId &&
          other.albumName == this.albumName &&
          other.albumId == this.albumId &&
          other.artworkUrl == this.artworkUrl &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.sourceId == this.sourceId &&
          other.licenseType == this.licenseType &&
          other.attributionString == this.attributionString &&
          other.sourceUrl == this.sourceUrl &&
          other.language == this.language &&
          other.durationMs == this.durationMs &&
          other.playCount == this.playCount &&
          other.offlineAllowed == this.offlineAllowed &&
          other.likedAt == this.likedAt);
}

class LikedTracksCompanion extends UpdateCompanion<LikedTrack> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> artistName;
  final Value<String> artistId;
  final Value<String> albumName;
  final Value<String> albumId;
  final Value<String?> artworkUrl;
  final Value<String?> thumbnailUrl;
  final Value<String> sourceId;
  final Value<String> licenseType;
  final Value<String> attributionString;
  final Value<String> sourceUrl;
  final Value<String> language;
  final Value<int> durationMs;
  final Value<int> playCount;
  final Value<bool> offlineAllowed;
  final Value<DateTime> likedAt;
  final Value<int> rowid;
  const LikedTracksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.artistName = const Value.absent(),
    this.artistId = const Value.absent(),
    this.albumName = const Value.absent(),
    this.albumId = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.licenseType = const Value.absent(),
    this.attributionString = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.language = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.playCount = const Value.absent(),
    this.offlineAllowed = const Value.absent(),
    this.likedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LikedTracksCompanion.insert({
    required String id,
    required String title,
    required String artistName,
    required String artistId,
    required String albumName,
    required String albumId,
    this.artworkUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    required String sourceId,
    required String licenseType,
    required String attributionString,
    required String sourceUrl,
    required String language,
    required int durationMs,
    required int playCount,
    required bool offlineAllowed,
    this.likedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        artistName = Value(artistName),
        artistId = Value(artistId),
        albumName = Value(albumName),
        albumId = Value(albumId),
        sourceId = Value(sourceId),
        licenseType = Value(licenseType),
        attributionString = Value(attributionString),
        sourceUrl = Value(sourceUrl),
        language = Value(language),
        durationMs = Value(durationMs),
        playCount = Value(playCount),
        offlineAllowed = Value(offlineAllowed);
  static Insertable<LikedTrack> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? artistName,
    Expression<String>? artistId,
    Expression<String>? albumName,
    Expression<String>? albumId,
    Expression<String>? artworkUrl,
    Expression<String>? thumbnailUrl,
    Expression<String>? sourceId,
    Expression<String>? licenseType,
    Expression<String>? attributionString,
    Expression<String>? sourceUrl,
    Expression<String>? language,
    Expression<int>? durationMs,
    Expression<int>? playCount,
    Expression<bool>? offlineAllowed,
    Expression<DateTime>? likedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (artistName != null) 'artist_name': artistName,
      if (artistId != null) 'artist_id': artistId,
      if (albumName != null) 'album_name': albumName,
      if (albumId != null) 'album_id': albumId,
      if (artworkUrl != null) 'artwork_url': artworkUrl,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (sourceId != null) 'source_id': sourceId,
      if (licenseType != null) 'license_type': licenseType,
      if (attributionString != null) 'attribution_string': attributionString,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (language != null) 'language': language,
      if (durationMs != null) 'duration_ms': durationMs,
      if (playCount != null) 'play_count': playCount,
      if (offlineAllowed != null) 'offline_allowed': offlineAllowed,
      if (likedAt != null) 'liked_at': likedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LikedTracksCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? artistName,
      Value<String>? artistId,
      Value<String>? albumName,
      Value<String>? albumId,
      Value<String?>? artworkUrl,
      Value<String?>? thumbnailUrl,
      Value<String>? sourceId,
      Value<String>? licenseType,
      Value<String>? attributionString,
      Value<String>? sourceUrl,
      Value<String>? language,
      Value<int>? durationMs,
      Value<int>? playCount,
      Value<bool>? offlineAllowed,
      Value<DateTime>? likedAt,
      Value<int>? rowid}) {
    return LikedTracksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      artistName: artistName ?? this.artistName,
      artistId: artistId ?? this.artistId,
      albumName: albumName ?? this.albumName,
      albumId: albumId ?? this.albumId,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      sourceId: sourceId ?? this.sourceId,
      licenseType: licenseType ?? this.licenseType,
      attributionString: attributionString ?? this.attributionString,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      language: language ?? this.language,
      durationMs: durationMs ?? this.durationMs,
      playCount: playCount ?? this.playCount,
      offlineAllowed: offlineAllowed ?? this.offlineAllowed,
      likedAt: likedAt ?? this.likedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artistName.present) {
      map['artist_name'] = Variable<String>(artistName.value);
    }
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (albumName.present) {
      map['album_name'] = Variable<String>(albumName.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (artworkUrl.present) {
      map['artwork_url'] = Variable<String>(artworkUrl.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (licenseType.present) {
      map['license_type'] = Variable<String>(licenseType.value);
    }
    if (attributionString.present) {
      map['attribution_string'] = Variable<String>(attributionString.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (offlineAllowed.present) {
      map['offline_allowed'] = Variable<bool>(offlineAllowed.value);
    }
    if (likedAt.present) {
      map['liked_at'] = Variable<DateTime>(likedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LikedTracksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artistName: $artistName, ')
          ..write('artistId: $artistId, ')
          ..write('albumName: $albumName, ')
          ..write('albumId: $albumId, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('sourceId: $sourceId, ')
          ..write('licenseType: $licenseType, ')
          ..write('attributionString: $attributionString, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('language: $language, ')
          ..write('durationMs: $durationMs, ')
          ..write('playCount: $playCount, ')
          ..write('offlineAllowed: $offlineAllowed, ')
          ..write('likedAt: $likedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTable extends Playlists
    with TableInfo<$PlaylistsTable, Playlist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _coverUrlMeta =
      const VerificationMeta('coverUrl');
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
      'cover_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, description, coverUrl, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(Insertable<Playlist> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('cover_url')) {
      context.handle(_coverUrlMeta,
          coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Playlist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Playlist(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      coverUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_url']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }
}

class Playlist extends DataClass implements Insertable<Playlist> {
  final int id;
  final String name;
  final String description;
  final String? coverUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Playlist(
      {required this.id,
      required this.name,
      required this.description,
      this.coverUrl,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Playlist.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Playlist(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Playlist copyWith(
          {int? id,
          String? name,
          String? description,
          Value<String?> coverUrl = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Playlist(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Playlist copyWithCompanion(PlaylistsCompanion data) {
    return Playlist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Playlist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, coverUrl, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Playlist &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.coverUrl == this.coverUrl &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PlaylistsCompanion extends UpdateCompanion<Playlist> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String?> coverUrl;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Playlist> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? coverUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PlaylistsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? description,
      Value<String?>? coverUrl,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return PlaylistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PlaylistTracksTable extends PlaylistTracks
    with TableInfo<$PlaylistTracksTable, PlaylistTrack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistTracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta =
      const VerificationMeta('playlistId');
  @override
  late final GeneratedColumn<int> playlistId = GeneratedColumn<int>(
      'playlist_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES playlists (id) ON DELETE CASCADE'));
  static const VerificationMeta _trackIdMeta =
      const VerificationMeta('trackId');
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
      'track_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _artistNameMeta =
      const VerificationMeta('artistName');
  @override
  late final GeneratedColumn<String> artistName = GeneratedColumn<String>(
      'artist_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _artworkUrlMeta =
      const VerificationMeta('artworkUrl');
  @override
  late final GeneratedColumn<String> artworkUrl = GeneratedColumn<String>(
      'artwork_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _licenseTypeMeta =
      const VerificationMeta('licenseType');
  @override
  late final GeneratedColumn<String> licenseType = GeneratedColumn<String>(
      'license_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _attributionStringMeta =
      const VerificationMeta('attributionString');
  @override
  late final GeneratedColumn<String> attributionString =
      GeneratedColumn<String>('attribution_string', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _trackJsonMeta =
      const VerificationMeta('trackJson');
  @override
  late final GeneratedColumn<String> trackJson = GeneratedColumn<String>(
      'track_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
      'added_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        playlistId,
        trackId,
        title,
        artistName,
        artworkUrl,
        sourceId,
        licenseType,
        attributionString,
        trackJson,
        sortOrder,
        addedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_tracks';
  @override
  VerificationContext validateIntegrity(Insertable<PlaylistTrack> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
          _playlistIdMeta,
          playlistId.isAcceptableOrUnknown(
              data['playlist_id']!, _playlistIdMeta));
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(_trackIdMeta,
          trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta));
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist_name')) {
      context.handle(
          _artistNameMeta,
          artistName.isAcceptableOrUnknown(
              data['artist_name']!, _artistNameMeta));
    } else if (isInserting) {
      context.missing(_artistNameMeta);
    }
    if (data.containsKey('artwork_url')) {
      context.handle(
          _artworkUrlMeta,
          artworkUrl.isAcceptableOrUnknown(
              data['artwork_url']!, _artworkUrlMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('license_type')) {
      context.handle(
          _licenseTypeMeta,
          licenseType.isAcceptableOrUnknown(
              data['license_type']!, _licenseTypeMeta));
    } else if (isInserting) {
      context.missing(_licenseTypeMeta);
    }
    if (data.containsKey('attribution_string')) {
      context.handle(
          _attributionStringMeta,
          attributionString.isAcceptableOrUnknown(
              data['attribution_string']!, _attributionStringMeta));
    } else if (isInserting) {
      context.missing(_attributionStringMeta);
    }
    if (data.containsKey('track_json')) {
      context.handle(_trackJsonMeta,
          trackJson.isAcceptableOrUnknown(data['track_json']!, _trackJsonMeta));
    } else if (isInserting) {
      context.missing(_trackJsonMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, trackId};
  @override
  PlaylistTrack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistTrack(
      playlistId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}playlist_id'])!,
      trackId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}track_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      artistName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artist_name'])!,
      artworkUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artwork_url']),
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      licenseType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}license_type'])!,
      attributionString: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}attribution_string'])!,
      trackJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}track_json'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_at'])!,
    );
  }

  @override
  $PlaylistTracksTable createAlias(String alias) {
    return $PlaylistTracksTable(attachedDatabase, alias);
  }
}

class PlaylistTrack extends DataClass implements Insertable<PlaylistTrack> {
  final int playlistId;
  final String trackId;
  final String title;
  final String artistName;
  final String? artworkUrl;
  final String sourceId;
  final String licenseType;
  final String attributionString;
  final String trackJson;
  final int sortOrder;
  final DateTime addedAt;
  const PlaylistTrack(
      {required this.playlistId,
      required this.trackId,
      required this.title,
      required this.artistName,
      this.artworkUrl,
      required this.sourceId,
      required this.licenseType,
      required this.attributionString,
      required this.trackJson,
      required this.sortOrder,
      required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<int>(playlistId);
    map['track_id'] = Variable<String>(trackId);
    map['title'] = Variable<String>(title);
    map['artist_name'] = Variable<String>(artistName);
    if (!nullToAbsent || artworkUrl != null) {
      map['artwork_url'] = Variable<String>(artworkUrl);
    }
    map['source_id'] = Variable<String>(sourceId);
    map['license_type'] = Variable<String>(licenseType);
    map['attribution_string'] = Variable<String>(attributionString);
    map['track_json'] = Variable<String>(trackJson);
    map['sort_order'] = Variable<int>(sortOrder);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  PlaylistTracksCompanion toCompanion(bool nullToAbsent) {
    return PlaylistTracksCompanion(
      playlistId: Value(playlistId),
      trackId: Value(trackId),
      title: Value(title),
      artistName: Value(artistName),
      artworkUrl: artworkUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkUrl),
      sourceId: Value(sourceId),
      licenseType: Value(licenseType),
      attributionString: Value(attributionString),
      trackJson: Value(trackJson),
      sortOrder: Value(sortOrder),
      addedAt: Value(addedAt),
    );
  }

  factory PlaylistTrack.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistTrack(
      playlistId: serializer.fromJson<int>(json['playlistId']),
      trackId: serializer.fromJson<String>(json['trackId']),
      title: serializer.fromJson<String>(json['title']),
      artistName: serializer.fromJson<String>(json['artistName']),
      artworkUrl: serializer.fromJson<String?>(json['artworkUrl']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      licenseType: serializer.fromJson<String>(json['licenseType']),
      attributionString: serializer.fromJson<String>(json['attributionString']),
      trackJson: serializer.fromJson<String>(json['trackJson']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<int>(playlistId),
      'trackId': serializer.toJson<String>(trackId),
      'title': serializer.toJson<String>(title),
      'artistName': serializer.toJson<String>(artistName),
      'artworkUrl': serializer.toJson<String?>(artworkUrl),
      'sourceId': serializer.toJson<String>(sourceId),
      'licenseType': serializer.toJson<String>(licenseType),
      'attributionString': serializer.toJson<String>(attributionString),
      'trackJson': serializer.toJson<String>(trackJson),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  PlaylistTrack copyWith(
          {int? playlistId,
          String? trackId,
          String? title,
          String? artistName,
          Value<String?> artworkUrl = const Value.absent(),
          String? sourceId,
          String? licenseType,
          String? attributionString,
          String? trackJson,
          int? sortOrder,
          DateTime? addedAt}) =>
      PlaylistTrack(
        playlistId: playlistId ?? this.playlistId,
        trackId: trackId ?? this.trackId,
        title: title ?? this.title,
        artistName: artistName ?? this.artistName,
        artworkUrl: artworkUrl.present ? artworkUrl.value : this.artworkUrl,
        sourceId: sourceId ?? this.sourceId,
        licenseType: licenseType ?? this.licenseType,
        attributionString: attributionString ?? this.attributionString,
        trackJson: trackJson ?? this.trackJson,
        sortOrder: sortOrder ?? this.sortOrder,
        addedAt: addedAt ?? this.addedAt,
      );
  PlaylistTrack copyWithCompanion(PlaylistTracksCompanion data) {
    return PlaylistTrack(
      playlistId:
          data.playlistId.present ? data.playlistId.value : this.playlistId,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      title: data.title.present ? data.title.value : this.title,
      artistName:
          data.artistName.present ? data.artistName.value : this.artistName,
      artworkUrl:
          data.artworkUrl.present ? data.artworkUrl.value : this.artworkUrl,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      licenseType:
          data.licenseType.present ? data.licenseType.value : this.licenseType,
      attributionString: data.attributionString.present
          ? data.attributionString.value
          : this.attributionString,
      trackJson: data.trackJson.present ? data.trackJson.value : this.trackJson,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTrack(')
          ..write('playlistId: $playlistId, ')
          ..write('trackId: $trackId, ')
          ..write('title: $title, ')
          ..write('artistName: $artistName, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('sourceId: $sourceId, ')
          ..write('licenseType: $licenseType, ')
          ..write('attributionString: $attributionString, ')
          ..write('trackJson: $trackJson, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      playlistId,
      trackId,
      title,
      artistName,
      artworkUrl,
      sourceId,
      licenseType,
      attributionString,
      trackJson,
      sortOrder,
      addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistTrack &&
          other.playlistId == this.playlistId &&
          other.trackId == this.trackId &&
          other.title == this.title &&
          other.artistName == this.artistName &&
          other.artworkUrl == this.artworkUrl &&
          other.sourceId == this.sourceId &&
          other.licenseType == this.licenseType &&
          other.attributionString == this.attributionString &&
          other.trackJson == this.trackJson &&
          other.sortOrder == this.sortOrder &&
          other.addedAt == this.addedAt);
}

class PlaylistTracksCompanion extends UpdateCompanion<PlaylistTrack> {
  final Value<int> playlistId;
  final Value<String> trackId;
  final Value<String> title;
  final Value<String> artistName;
  final Value<String?> artworkUrl;
  final Value<String> sourceId;
  final Value<String> licenseType;
  final Value<String> attributionString;
  final Value<String> trackJson;
  final Value<int> sortOrder;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const PlaylistTracksCompanion({
    this.playlistId = const Value.absent(),
    this.trackId = const Value.absent(),
    this.title = const Value.absent(),
    this.artistName = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.licenseType = const Value.absent(),
    this.attributionString = const Value.absent(),
    this.trackJson = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistTracksCompanion.insert({
    required int playlistId,
    required String trackId,
    required String title,
    required String artistName,
    this.artworkUrl = const Value.absent(),
    required String sourceId,
    required String licenseType,
    required String attributionString,
    required String trackJson,
    required int sortOrder,
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : playlistId = Value(playlistId),
        trackId = Value(trackId),
        title = Value(title),
        artistName = Value(artistName),
        sourceId = Value(sourceId),
        licenseType = Value(licenseType),
        attributionString = Value(attributionString),
        trackJson = Value(trackJson),
        sortOrder = Value(sortOrder);
  static Insertable<PlaylistTrack> custom({
    Expression<int>? playlistId,
    Expression<String>? trackId,
    Expression<String>? title,
    Expression<String>? artistName,
    Expression<String>? artworkUrl,
    Expression<String>? sourceId,
    Expression<String>? licenseType,
    Expression<String>? attributionString,
    Expression<String>? trackJson,
    Expression<int>? sortOrder,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (trackId != null) 'track_id': trackId,
      if (title != null) 'title': title,
      if (artistName != null) 'artist_name': artistName,
      if (artworkUrl != null) 'artwork_url': artworkUrl,
      if (sourceId != null) 'source_id': sourceId,
      if (licenseType != null) 'license_type': licenseType,
      if (attributionString != null) 'attribution_string': attributionString,
      if (trackJson != null) 'track_json': trackJson,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistTracksCompanion copyWith(
      {Value<int>? playlistId,
      Value<String>? trackId,
      Value<String>? title,
      Value<String>? artistName,
      Value<String?>? artworkUrl,
      Value<String>? sourceId,
      Value<String>? licenseType,
      Value<String>? attributionString,
      Value<String>? trackJson,
      Value<int>? sortOrder,
      Value<DateTime>? addedAt,
      Value<int>? rowid}) {
    return PlaylistTracksCompanion(
      playlistId: playlistId ?? this.playlistId,
      trackId: trackId ?? this.trackId,
      title: title ?? this.title,
      artistName: artistName ?? this.artistName,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      sourceId: sourceId ?? this.sourceId,
      licenseType: licenseType ?? this.licenseType,
      attributionString: attributionString ?? this.attributionString,
      trackJson: trackJson ?? this.trackJson,
      sortOrder: sortOrder ?? this.sortOrder,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<int>(playlistId.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artistName.present) {
      map['artist_name'] = Variable<String>(artistName.value);
    }
    if (artworkUrl.present) {
      map['artwork_url'] = Variable<String>(artworkUrl.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (licenseType.present) {
      map['license_type'] = Variable<String>(licenseType.value);
    }
    if (attributionString.present) {
      map['attribution_string'] = Variable<String>(attributionString.value);
    }
    if (trackJson.present) {
      map['track_json'] = Variable<String>(trackJson.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTracksCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('trackId: $trackId, ')
          ..write('title: $title, ')
          ..write('artistName: $artistName, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('sourceId: $sourceId, ')
          ..write('licenseType: $licenseType, ')
          ..write('attributionString: $attributionString, ')
          ..write('trackJson: $trackJson, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadedFilesTable extends DownloadedFiles
    with TableInfo<$DownloadedFilesTable, DownloadedFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadedFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta =
      const VerificationMeta('trackId');
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
      'track_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sizeBytesMeta =
      const VerificationMeta('sizeBytes');
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
      'size_bytes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _downloadedAtMeta =
      const VerificationMeta('downloadedAt');
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
      'downloaded_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _artistNameMeta =
      const VerificationMeta('artistName');
  @override
  late final GeneratedColumn<String> artistName = GeneratedColumn<String>(
      'artist_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _artworkUrlMeta =
      const VerificationMeta('artworkUrl');
  @override
  late final GeneratedColumn<String> artworkUrl = GeneratedColumn<String>(
      'artwork_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        trackId,
        localPath,
        sizeBytes,
        downloadedAt,
        title,
        artistName,
        artworkUrl
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloaded_files';
  @override
  VerificationContext validateIntegrity(Insertable<DownloadedFile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(_trackIdMeta,
          trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta));
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(_sizeBytesMeta,
          sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta));
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
          _downloadedAtMeta,
          downloadedAt.isAcceptableOrUnknown(
              data['downloaded_at']!, _downloadedAtMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('artist_name')) {
      context.handle(
          _artistNameMeta,
          artistName.isAcceptableOrUnknown(
              data['artist_name']!, _artistNameMeta));
    }
    if (data.containsKey('artwork_url')) {
      context.handle(
          _artworkUrlMeta,
          artworkUrl.isAcceptableOrUnknown(
              data['artwork_url']!, _artworkUrlMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  DownloadedFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadedFile(
      trackId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}track_id'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path'])!,
      sizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size_bytes'])!,
      downloadedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}downloaded_at'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      artistName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artist_name']),
      artworkUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artwork_url']),
    );
  }

  @override
  $DownloadedFilesTable createAlias(String alias) {
    return $DownloadedFilesTable(attachedDatabase, alias);
  }
}

class DownloadedFile extends DataClass implements Insertable<DownloadedFile> {
  final String trackId;
  final String localPath;
  final int sizeBytes;
  final DateTime downloadedAt;
  final String? title;
  final String? artistName;
  final String? artworkUrl;
  const DownloadedFile(
      {required this.trackId,
      required this.localPath,
      required this.sizeBytes,
      required this.downloadedAt,
      this.title,
      this.artistName,
      this.artworkUrl});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['local_path'] = Variable<String>(localPath);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || artistName != null) {
      map['artist_name'] = Variable<String>(artistName);
    }
    if (!nullToAbsent || artworkUrl != null) {
      map['artwork_url'] = Variable<String>(artworkUrl);
    }
    return map;
  }

  DownloadedFilesCompanion toCompanion(bool nullToAbsent) {
    return DownloadedFilesCompanion(
      trackId: Value(trackId),
      localPath: Value(localPath),
      sizeBytes: Value(sizeBytes),
      downloadedAt: Value(downloadedAt),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      artistName: artistName == null && nullToAbsent
          ? const Value.absent()
          : Value(artistName),
      artworkUrl: artworkUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkUrl),
    );
  }

  factory DownloadedFile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadedFile(
      trackId: serializer.fromJson<String>(json['trackId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
      title: serializer.fromJson<String?>(json['title']),
      artistName: serializer.fromJson<String?>(json['artistName']),
      artworkUrl: serializer.fromJson<String?>(json['artworkUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'localPath': serializer.toJson<String>(localPath),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
      'title': serializer.toJson<String?>(title),
      'artistName': serializer.toJson<String?>(artistName),
      'artworkUrl': serializer.toJson<String?>(artworkUrl),
    };
  }

  DownloadedFile copyWith(
          {String? trackId,
          String? localPath,
          int? sizeBytes,
          DateTime? downloadedAt,
          Value<String?> title = const Value.absent(),
          Value<String?> artistName = const Value.absent(),
          Value<String?> artworkUrl = const Value.absent()}) =>
      DownloadedFile(
        trackId: trackId ?? this.trackId,
        localPath: localPath ?? this.localPath,
        sizeBytes: sizeBytes ?? this.sizeBytes,
        downloadedAt: downloadedAt ?? this.downloadedAt,
        title: title.present ? title.value : this.title,
        artistName: artistName.present ? artistName.value : this.artistName,
        artworkUrl: artworkUrl.present ? artworkUrl.value : this.artworkUrl,
      );
  DownloadedFile copyWithCompanion(DownloadedFilesCompanion data) {
    return DownloadedFile(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
      title: data.title.present ? data.title.value : this.title,
      artistName:
          data.artistName.present ? data.artistName.value : this.artistName,
      artworkUrl:
          data.artworkUrl.present ? data.artworkUrl.value : this.artworkUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedFile(')
          ..write('trackId: $trackId, ')
          ..write('localPath: $localPath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('title: $title, ')
          ..write('artistName: $artistName, ')
          ..write('artworkUrl: $artworkUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trackId, localPath, sizeBytes, downloadedAt,
      title, artistName, artworkUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadedFile &&
          other.trackId == this.trackId &&
          other.localPath == this.localPath &&
          other.sizeBytes == this.sizeBytes &&
          other.downloadedAt == this.downloadedAt &&
          other.title == this.title &&
          other.artistName == this.artistName &&
          other.artworkUrl == this.artworkUrl);
}

class DownloadedFilesCompanion extends UpdateCompanion<DownloadedFile> {
  final Value<String> trackId;
  final Value<String> localPath;
  final Value<int> sizeBytes;
  final Value<DateTime> downloadedAt;
  final Value<String?> title;
  final Value<String?> artistName;
  final Value<String?> artworkUrl;
  final Value<int> rowid;
  const DownloadedFilesCompanion({
    this.trackId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.title = const Value.absent(),
    this.artistName = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadedFilesCompanion.insert({
    required String trackId,
    required String localPath,
    required int sizeBytes,
    this.downloadedAt = const Value.absent(),
    this.title = const Value.absent(),
    this.artistName = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : trackId = Value(trackId),
        localPath = Value(localPath),
        sizeBytes = Value(sizeBytes);
  static Insertable<DownloadedFile> custom({
    Expression<String>? trackId,
    Expression<String>? localPath,
    Expression<int>? sizeBytes,
    Expression<DateTime>? downloadedAt,
    Expression<String>? title,
    Expression<String>? artistName,
    Expression<String>? artworkUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (localPath != null) 'local_path': localPath,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (title != null) 'title': title,
      if (artistName != null) 'artist_name': artistName,
      if (artworkUrl != null) 'artwork_url': artworkUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadedFilesCompanion copyWith(
      {Value<String>? trackId,
      Value<String>? localPath,
      Value<int>? sizeBytes,
      Value<DateTime>? downloadedAt,
      Value<String?>? title,
      Value<String?>? artistName,
      Value<String?>? artworkUrl,
      Value<int>? rowid}) {
    return DownloadedFilesCompanion(
      trackId: trackId ?? this.trackId,
      localPath: localPath ?? this.localPath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      title: title ?? this.title,
      artistName: artistName ?? this.artistName,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artistName.present) {
      map['artist_name'] = Variable<String>(artistName.value);
    }
    if (artworkUrl.present) {
      map['artwork_url'] = Variable<String>(artworkUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedFilesCompanion(')
          ..write('trackId: $trackId, ')
          ..write('localPath: $localPath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('title: $title, ')
          ..write('artistName: $artistName, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecentSearchesTable extends RecentSearches
    with TableInfo<$RecentSearchesTable, RecentSearche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentSearchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
      'query', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _searchedAtMeta =
      const VerificationMeta('searchedAt');
  @override
  late final GeneratedColumn<DateTime> searchedAt = GeneratedColumn<DateTime>(
      'searched_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [query, searchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_searches';
  @override
  VerificationContext validateIntegrity(Insertable<RecentSearche> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('query')) {
      context.handle(
          _queryMeta, query.isAcceptableOrUnknown(data['query']!, _queryMeta));
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('searched_at')) {
      context.handle(
          _searchedAtMeta,
          searchedAt.isAcceptableOrUnknown(
              data['searched_at']!, _searchedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {query};
  @override
  RecentSearche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentSearche(
      query: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}query'])!,
      searchedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}searched_at'])!,
    );
  }

  @override
  $RecentSearchesTable createAlias(String alias) {
    return $RecentSearchesTable(attachedDatabase, alias);
  }
}

class RecentSearche extends DataClass implements Insertable<RecentSearche> {
  final String query;
  final DateTime searchedAt;
  const RecentSearche({required this.query, required this.searchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['query'] = Variable<String>(query);
    map['searched_at'] = Variable<DateTime>(searchedAt);
    return map;
  }

  RecentSearchesCompanion toCompanion(bool nullToAbsent) {
    return RecentSearchesCompanion(
      query: Value(query),
      searchedAt: Value(searchedAt),
    );
  }

  factory RecentSearche.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentSearche(
      query: serializer.fromJson<String>(json['query']),
      searchedAt: serializer.fromJson<DateTime>(json['searchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'query': serializer.toJson<String>(query),
      'searchedAt': serializer.toJson<DateTime>(searchedAt),
    };
  }

  RecentSearche copyWith({String? query, DateTime? searchedAt}) =>
      RecentSearche(
        query: query ?? this.query,
        searchedAt: searchedAt ?? this.searchedAt,
      );
  RecentSearche copyWithCompanion(RecentSearchesCompanion data) {
    return RecentSearche(
      query: data.query.present ? data.query.value : this.query,
      searchedAt:
          data.searchedAt.present ? data.searchedAt.value : this.searchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearche(')
          ..write('query: $query, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(query, searchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentSearche &&
          other.query == this.query &&
          other.searchedAt == this.searchedAt);
}

class RecentSearchesCompanion extends UpdateCompanion<RecentSearche> {
  final Value<String> query;
  final Value<DateTime> searchedAt;
  final Value<int> rowid;
  const RecentSearchesCompanion({
    this.query = const Value.absent(),
    this.searchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecentSearchesCompanion.insert({
    required String query,
    this.searchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : query = Value(query);
  static Insertable<RecentSearche> custom({
    Expression<String>? query,
    Expression<DateTime>? searchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (query != null) 'query': query,
      if (searchedAt != null) 'searched_at': searchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecentSearchesCompanion copyWith(
      {Value<String>? query, Value<DateTime>? searchedAt, Value<int>? rowid}) {
    return RecentSearchesCompanion(
      query: query ?? this.query,
      searchedAt: searchedAt ?? this.searchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (searchedAt.present) {
      map['searched_at'] = Variable<DateTime>(searchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearchesCompanion(')
          ..write('query: $query, ')
          ..write('searchedAt: $searchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubscribedPodcastsTable extends SubscribedPodcasts
    with TableInfo<$SubscribedPodcastsTable, SubscribedPodcast> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscribedPodcastsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _artworkUrlMeta =
      const VerificationMeta('artworkUrl');
  @override
  late final GeneratedColumn<String> artworkUrl = GeneratedColumn<String>(
      'artwork_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _feedUrlMeta =
      const VerificationMeta('feedUrl');
  @override
  late final GeneratedColumn<String> feedUrl = GeneratedColumn<String>(
      'feed_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subscribedAtMeta =
      const VerificationMeta('subscribedAt');
  @override
  late final GeneratedColumn<DateTime> subscribedAt = GeneratedColumn<DateTime>(
      'subscribed_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, author, description, artworkUrl, feedUrl, subscribedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscribed_podcasts';
  @override
  VerificationContext validateIntegrity(Insertable<SubscribedPodcast> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    } else if (isInserting) {
      context.missing(_authorMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('artwork_url')) {
      context.handle(
          _artworkUrlMeta,
          artworkUrl.isAcceptableOrUnknown(
              data['artwork_url']!, _artworkUrlMeta));
    }
    if (data.containsKey('feed_url')) {
      context.handle(_feedUrlMeta,
          feedUrl.isAcceptableOrUnknown(data['feed_url']!, _feedUrlMeta));
    } else if (isInserting) {
      context.missing(_feedUrlMeta);
    }
    if (data.containsKey('subscribed_at')) {
      context.handle(
          _subscribedAtMeta,
          subscribedAt.isAcceptableOrUnknown(
              data['subscribed_at']!, _subscribedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubscribedPodcast map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubscribedPodcast(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      artworkUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artwork_url']),
      feedUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}feed_url'])!,
      subscribedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}subscribed_at'])!,
    );
  }

  @override
  $SubscribedPodcastsTable createAlias(String alias) {
    return $SubscribedPodcastsTable(attachedDatabase, alias);
  }
}

class SubscribedPodcast extends DataClass
    implements Insertable<SubscribedPodcast> {
  final String id;
  final String title;
  final String author;
  final String description;
  final String? artworkUrl;
  final String feedUrl;
  final DateTime subscribedAt;
  const SubscribedPodcast(
      {required this.id,
      required this.title,
      required this.author,
      required this.description,
      this.artworkUrl,
      required this.feedUrl,
      required this.subscribedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['author'] = Variable<String>(author);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || artworkUrl != null) {
      map['artwork_url'] = Variable<String>(artworkUrl);
    }
    map['feed_url'] = Variable<String>(feedUrl);
    map['subscribed_at'] = Variable<DateTime>(subscribedAt);
    return map;
  }

  SubscribedPodcastsCompanion toCompanion(bool nullToAbsent) {
    return SubscribedPodcastsCompanion(
      id: Value(id),
      title: Value(title),
      author: Value(author),
      description: Value(description),
      artworkUrl: artworkUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkUrl),
      feedUrl: Value(feedUrl),
      subscribedAt: Value(subscribedAt),
    );
  }

  factory SubscribedPodcast.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubscribedPodcast(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String>(json['author']),
      description: serializer.fromJson<String>(json['description']),
      artworkUrl: serializer.fromJson<String?>(json['artworkUrl']),
      feedUrl: serializer.fromJson<String>(json['feedUrl']),
      subscribedAt: serializer.fromJson<DateTime>(json['subscribedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String>(author),
      'description': serializer.toJson<String>(description),
      'artworkUrl': serializer.toJson<String?>(artworkUrl),
      'feedUrl': serializer.toJson<String>(feedUrl),
      'subscribedAt': serializer.toJson<DateTime>(subscribedAt),
    };
  }

  SubscribedPodcast copyWith(
          {String? id,
          String? title,
          String? author,
          String? description,
          Value<String?> artworkUrl = const Value.absent(),
          String? feedUrl,
          DateTime? subscribedAt}) =>
      SubscribedPodcast(
        id: id ?? this.id,
        title: title ?? this.title,
        author: author ?? this.author,
        description: description ?? this.description,
        artworkUrl: artworkUrl.present ? artworkUrl.value : this.artworkUrl,
        feedUrl: feedUrl ?? this.feedUrl,
        subscribedAt: subscribedAt ?? this.subscribedAt,
      );
  SubscribedPodcast copyWithCompanion(SubscribedPodcastsCompanion data) {
    return SubscribedPodcast(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      description:
          data.description.present ? data.description.value : this.description,
      artworkUrl:
          data.artworkUrl.present ? data.artworkUrl.value : this.artworkUrl,
      feedUrl: data.feedUrl.present ? data.feedUrl.value : this.feedUrl,
      subscribedAt: data.subscribedAt.present
          ? data.subscribedAt.value
          : this.subscribedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubscribedPodcast(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('description: $description, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('subscribedAt: $subscribedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, title, author, description, artworkUrl, feedUrl, subscribedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscribedPodcast &&
          other.id == this.id &&
          other.title == this.title &&
          other.author == this.author &&
          other.description == this.description &&
          other.artworkUrl == this.artworkUrl &&
          other.feedUrl == this.feedUrl &&
          other.subscribedAt == this.subscribedAt);
}

class SubscribedPodcastsCompanion extends UpdateCompanion<SubscribedPodcast> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> author;
  final Value<String> description;
  final Value<String?> artworkUrl;
  final Value<String> feedUrl;
  final Value<DateTime> subscribedAt;
  final Value<int> rowid;
  const SubscribedPodcastsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.description = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.feedUrl = const Value.absent(),
    this.subscribedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubscribedPodcastsCompanion.insert({
    required String id,
    required String title,
    required String author,
    required String description,
    this.artworkUrl = const Value.absent(),
    required String feedUrl,
    this.subscribedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        author = Value(author),
        description = Value(description),
        feedUrl = Value(feedUrl);
  static Insertable<SubscribedPodcast> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? description,
    Expression<String>? artworkUrl,
    Expression<String>? feedUrl,
    Expression<DateTime>? subscribedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (description != null) 'description': description,
      if (artworkUrl != null) 'artwork_url': artworkUrl,
      if (feedUrl != null) 'feed_url': feedUrl,
      if (subscribedAt != null) 'subscribed_at': subscribedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubscribedPodcastsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? author,
      Value<String>? description,
      Value<String?>? artworkUrl,
      Value<String>? feedUrl,
      Value<DateTime>? subscribedAt,
      Value<int>? rowid}) {
    return SubscribedPodcastsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      feedUrl: feedUrl ?? this.feedUrl,
      subscribedAt: subscribedAt ?? this.subscribedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (artworkUrl.present) {
      map['artwork_url'] = Variable<String>(artworkUrl.value);
    }
    if (feedUrl.present) {
      map['feed_url'] = Variable<String>(feedUrl.value);
    }
    if (subscribedAt.present) {
      map['subscribed_at'] = Variable<DateTime>(subscribedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscribedPodcastsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('description: $description, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('subscribedAt: $subscribedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PodcastEpisodesProgressTable extends PodcastEpisodesProgress
    with TableInfo<$PodcastEpisodesProgressTable, PodcastEpisodesProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PodcastEpisodesProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _episodeIdMeta =
      const VerificationMeta('episodeId');
  @override
  late final GeneratedColumn<String> episodeId = GeneratedColumn<String>(
      'episode_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _podcastIdMeta =
      const VerificationMeta('podcastId');
  @override
  late final GeneratedColumn<String> podcastId = GeneratedColumn<String>(
      'podcast_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES subscribed_podcasts (id) ON DELETE CASCADE'));
  static const VerificationMeta _progressMsMeta =
      const VerificationMeta('progressMs');
  @override
  late final GeneratedColumn<int> progressMs = GeneratedColumn<int>(
      'progress_ms', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastListenedAtMeta =
      const VerificationMeta('lastListenedAt');
  @override
  late final GeneratedColumn<DateTime> lastListenedAt =
      GeneratedColumn<DateTime>('last_listened_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        episodeId,
        podcastId,
        progressMs,
        durationMs,
        isCompleted,
        lastListenedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'podcast_episodes_progress';
  @override
  VerificationContext validateIntegrity(
      Insertable<PodcastEpisodesProgressData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('episode_id')) {
      context.handle(_episodeIdMeta,
          episodeId.isAcceptableOrUnknown(data['episode_id']!, _episodeIdMeta));
    } else if (isInserting) {
      context.missing(_episodeIdMeta);
    }
    if (data.containsKey('podcast_id')) {
      context.handle(_podcastIdMeta,
          podcastId.isAcceptableOrUnknown(data['podcast_id']!, _podcastIdMeta));
    } else if (isInserting) {
      context.missing(_podcastIdMeta);
    }
    if (data.containsKey('progress_ms')) {
      context.handle(
          _progressMsMeta,
          progressMs.isAcceptableOrUnknown(
              data['progress_ms']!, _progressMsMeta));
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('last_listened_at')) {
      context.handle(
          _lastListenedAtMeta,
          lastListenedAt.isAcceptableOrUnknown(
              data['last_listened_at']!, _lastListenedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {episodeId};
  @override
  PodcastEpisodesProgressData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PodcastEpisodesProgressData(
      episodeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}episode_id'])!,
      podcastId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}podcast_id'])!,
      progressMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}progress_ms'])!,
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      lastListenedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_listened_at'])!,
    );
  }

  @override
  $PodcastEpisodesProgressTable createAlias(String alias) {
    return $PodcastEpisodesProgressTable(attachedDatabase, alias);
  }
}

class PodcastEpisodesProgressData extends DataClass
    implements Insertable<PodcastEpisodesProgressData> {
  final String episodeId;
  final String podcastId;
  final int progressMs;
  final int durationMs;
  final bool isCompleted;
  final DateTime lastListenedAt;
  const PodcastEpisodesProgressData(
      {required this.episodeId,
      required this.podcastId,
      required this.progressMs,
      required this.durationMs,
      required this.isCompleted,
      required this.lastListenedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['episode_id'] = Variable<String>(episodeId);
    map['podcast_id'] = Variable<String>(podcastId);
    map['progress_ms'] = Variable<int>(progressMs);
    map['duration_ms'] = Variable<int>(durationMs);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['last_listened_at'] = Variable<DateTime>(lastListenedAt);
    return map;
  }

  PodcastEpisodesProgressCompanion toCompanion(bool nullToAbsent) {
    return PodcastEpisodesProgressCompanion(
      episodeId: Value(episodeId),
      podcastId: Value(podcastId),
      progressMs: Value(progressMs),
      durationMs: Value(durationMs),
      isCompleted: Value(isCompleted),
      lastListenedAt: Value(lastListenedAt),
    );
  }

  factory PodcastEpisodesProgressData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PodcastEpisodesProgressData(
      episodeId: serializer.fromJson<String>(json['episodeId']),
      podcastId: serializer.fromJson<String>(json['podcastId']),
      progressMs: serializer.fromJson<int>(json['progressMs']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      lastListenedAt: serializer.fromJson<DateTime>(json['lastListenedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'episodeId': serializer.toJson<String>(episodeId),
      'podcastId': serializer.toJson<String>(podcastId),
      'progressMs': serializer.toJson<int>(progressMs),
      'durationMs': serializer.toJson<int>(durationMs),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'lastListenedAt': serializer.toJson<DateTime>(lastListenedAt),
    };
  }

  PodcastEpisodesProgressData copyWith(
          {String? episodeId,
          String? podcastId,
          int? progressMs,
          int? durationMs,
          bool? isCompleted,
          DateTime? lastListenedAt}) =>
      PodcastEpisodesProgressData(
        episodeId: episodeId ?? this.episodeId,
        podcastId: podcastId ?? this.podcastId,
        progressMs: progressMs ?? this.progressMs,
        durationMs: durationMs ?? this.durationMs,
        isCompleted: isCompleted ?? this.isCompleted,
        lastListenedAt: lastListenedAt ?? this.lastListenedAt,
      );
  PodcastEpisodesProgressData copyWithCompanion(
      PodcastEpisodesProgressCompanion data) {
    return PodcastEpisodesProgressData(
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      podcastId: data.podcastId.present ? data.podcastId.value : this.podcastId,
      progressMs:
          data.progressMs.present ? data.progressMs.value : this.progressMs,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      lastListenedAt: data.lastListenedAt.present
          ? data.lastListenedAt.value
          : this.lastListenedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PodcastEpisodesProgressData(')
          ..write('episodeId: $episodeId, ')
          ..write('podcastId: $podcastId, ')
          ..write('progressMs: $progressMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('lastListenedAt: $lastListenedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(episodeId, podcastId, progressMs, durationMs,
      isCompleted, lastListenedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PodcastEpisodesProgressData &&
          other.episodeId == this.episodeId &&
          other.podcastId == this.podcastId &&
          other.progressMs == this.progressMs &&
          other.durationMs == this.durationMs &&
          other.isCompleted == this.isCompleted &&
          other.lastListenedAt == this.lastListenedAt);
}

class PodcastEpisodesProgressCompanion
    extends UpdateCompanion<PodcastEpisodesProgressData> {
  final Value<String> episodeId;
  final Value<String> podcastId;
  final Value<int> progressMs;
  final Value<int> durationMs;
  final Value<bool> isCompleted;
  final Value<DateTime> lastListenedAt;
  final Value<int> rowid;
  const PodcastEpisodesProgressCompanion({
    this.episodeId = const Value.absent(),
    this.podcastId = const Value.absent(),
    this.progressMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.lastListenedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PodcastEpisodesProgressCompanion.insert({
    required String episodeId,
    required String podcastId,
    this.progressMs = const Value.absent(),
    required int durationMs,
    this.isCompleted = const Value.absent(),
    this.lastListenedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : episodeId = Value(episodeId),
        podcastId = Value(podcastId),
        durationMs = Value(durationMs);
  static Insertable<PodcastEpisodesProgressData> custom({
    Expression<String>? episodeId,
    Expression<String>? podcastId,
    Expression<int>? progressMs,
    Expression<int>? durationMs,
    Expression<bool>? isCompleted,
    Expression<DateTime>? lastListenedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (episodeId != null) 'episode_id': episodeId,
      if (podcastId != null) 'podcast_id': podcastId,
      if (progressMs != null) 'progress_ms': progressMs,
      if (durationMs != null) 'duration_ms': durationMs,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (lastListenedAt != null) 'last_listened_at': lastListenedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PodcastEpisodesProgressCompanion copyWith(
      {Value<String>? episodeId,
      Value<String>? podcastId,
      Value<int>? progressMs,
      Value<int>? durationMs,
      Value<bool>? isCompleted,
      Value<DateTime>? lastListenedAt,
      Value<int>? rowid}) {
    return PodcastEpisodesProgressCompanion(
      episodeId: episodeId ?? this.episodeId,
      podcastId: podcastId ?? this.podcastId,
      progressMs: progressMs ?? this.progressMs,
      durationMs: durationMs ?? this.durationMs,
      isCompleted: isCompleted ?? this.isCompleted,
      lastListenedAt: lastListenedAt ?? this.lastListenedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (episodeId.present) {
      map['episode_id'] = Variable<String>(episodeId.value);
    }
    if (podcastId.present) {
      map['podcast_id'] = Variable<String>(podcastId.value);
    }
    if (progressMs.present) {
      map['progress_ms'] = Variable<int>(progressMs.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (lastListenedAt.present) {
      map['last_listened_at'] = Variable<DateTime>(lastListenedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PodcastEpisodesProgressCompanion(')
          ..write('episodeId: $episodeId, ')
          ..write('podcastId: $podcastId, ')
          ..write('progressMs: $progressMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('lastListenedAt: $lastListenedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AuxDatabase extends GeneratedDatabase {
  _$AuxDatabase(QueryExecutor e) : super(e);
  $AuxDatabaseManager get managers => $AuxDatabaseManager(this);
  late final $LikedTracksTable likedTracks = $LikedTracksTable(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $PlaylistTracksTable playlistTracks = $PlaylistTracksTable(this);
  late final $DownloadedFilesTable downloadedFiles =
      $DownloadedFilesTable(this);
  late final $RecentSearchesTable recentSearches = $RecentSearchesTable(this);
  late final $SubscribedPodcastsTable subscribedPodcasts =
      $SubscribedPodcastsTable(this);
  late final $PodcastEpisodesProgressTable podcastEpisodesProgress =
      $PodcastEpisodesProgressTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        likedTracks,
        playlists,
        playlistTracks,
        downloadedFiles,
        recentSearches,
        subscribedPodcasts,
        podcastEpisodesProgress
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('playlists',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('playlist_tracks', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('subscribed_podcasts',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('podcast_episodes_progress', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$LikedTracksTableCreateCompanionBuilder = LikedTracksCompanion
    Function({
  required String id,
  required String title,
  required String artistName,
  required String artistId,
  required String albumName,
  required String albumId,
  Value<String?> artworkUrl,
  Value<String?> thumbnailUrl,
  required String sourceId,
  required String licenseType,
  required String attributionString,
  required String sourceUrl,
  required String language,
  required int durationMs,
  required int playCount,
  required bool offlineAllowed,
  Value<DateTime> likedAt,
  Value<int> rowid,
});
typedef $$LikedTracksTableUpdateCompanionBuilder = LikedTracksCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String> artistName,
  Value<String> artistId,
  Value<String> albumName,
  Value<String> albumId,
  Value<String?> artworkUrl,
  Value<String?> thumbnailUrl,
  Value<String> sourceId,
  Value<String> licenseType,
  Value<String> attributionString,
  Value<String> sourceUrl,
  Value<String> language,
  Value<int> durationMs,
  Value<int> playCount,
  Value<bool> offlineAllowed,
  Value<DateTime> likedAt,
  Value<int> rowid,
});

class $$LikedTracksTableFilterComposer
    extends Composer<_$AuxDatabase, $LikedTracksTable> {
  $$LikedTracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get artistName => $composableBuilder(
      column: $table.artistName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get artistId => $composableBuilder(
      column: $table.artistId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get albumName => $composableBuilder(
      column: $table.albumName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get albumId => $composableBuilder(
      column: $table.albumId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get artworkUrl => $composableBuilder(
      column: $table.artworkUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get licenseType => $composableBuilder(
      column: $table.licenseType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get attributionString => $composableBuilder(
      column: $table.attributionString,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceUrl => $composableBuilder(
      column: $table.sourceUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get playCount => $composableBuilder(
      column: $table.playCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get offlineAllowed => $composableBuilder(
      column: $table.offlineAllowed,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get likedAt => $composableBuilder(
      column: $table.likedAt, builder: (column) => ColumnFilters(column));
}

class $$LikedTracksTableOrderingComposer
    extends Composer<_$AuxDatabase, $LikedTracksTable> {
  $$LikedTracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get artistName => $composableBuilder(
      column: $table.artistName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get artistId => $composableBuilder(
      column: $table.artistId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get albumName => $composableBuilder(
      column: $table.albumName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get albumId => $composableBuilder(
      column: $table.albumId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get artworkUrl => $composableBuilder(
      column: $table.artworkUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get licenseType => $composableBuilder(
      column: $table.licenseType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get attributionString => $composableBuilder(
      column: $table.attributionString,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
      column: $table.sourceUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get playCount => $composableBuilder(
      column: $table.playCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get offlineAllowed => $composableBuilder(
      column: $table.offlineAllowed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get likedAt => $composableBuilder(
      column: $table.likedAt, builder: (column) => ColumnOrderings(column));
}

class $$LikedTracksTableAnnotationComposer
    extends Composer<_$AuxDatabase, $LikedTracksTable> {
  $$LikedTracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artistName => $composableBuilder(
      column: $table.artistName, builder: (column) => column);

  GeneratedColumn<String> get artistId =>
      $composableBuilder(column: $table.artistId, builder: (column) => column);

  GeneratedColumn<String> get albumName =>
      $composableBuilder(column: $table.albumName, builder: (column) => column);

  GeneratedColumn<String> get albumId =>
      $composableBuilder(column: $table.albumId, builder: (column) => column);

  GeneratedColumn<String> get artworkUrl => $composableBuilder(
      column: $table.artworkUrl, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get licenseType => $composableBuilder(
      column: $table.licenseType, builder: (column) => column);

  GeneratedColumn<String> get attributionString => $composableBuilder(
      column: $table.attributionString, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<bool> get offlineAllowed => $composableBuilder(
      column: $table.offlineAllowed, builder: (column) => column);

  GeneratedColumn<DateTime> get likedAt =>
      $composableBuilder(column: $table.likedAt, builder: (column) => column);
}

class $$LikedTracksTableTableManager extends RootTableManager<
    _$AuxDatabase,
    $LikedTracksTable,
    LikedTrack,
    $$LikedTracksTableFilterComposer,
    $$LikedTracksTableOrderingComposer,
    $$LikedTracksTableAnnotationComposer,
    $$LikedTracksTableCreateCompanionBuilder,
    $$LikedTracksTableUpdateCompanionBuilder,
    (LikedTrack, BaseReferences<_$AuxDatabase, $LikedTracksTable, LikedTrack>),
    LikedTrack,
    PrefetchHooks Function()> {
  $$LikedTracksTableTableManager(_$AuxDatabase db, $LikedTracksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LikedTracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LikedTracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LikedTracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> artistName = const Value.absent(),
            Value<String> artistId = const Value.absent(),
            Value<String> albumName = const Value.absent(),
            Value<String> albumId = const Value.absent(),
            Value<String?> artworkUrl = const Value.absent(),
            Value<String?> thumbnailUrl = const Value.absent(),
            Value<String> sourceId = const Value.absent(),
            Value<String> licenseType = const Value.absent(),
            Value<String> attributionString = const Value.absent(),
            Value<String> sourceUrl = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<int> playCount = const Value.absent(),
            Value<bool> offlineAllowed = const Value.absent(),
            Value<DateTime> likedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LikedTracksCompanion(
            id: id,
            title: title,
            artistName: artistName,
            artistId: artistId,
            albumName: albumName,
            albumId: albumId,
            artworkUrl: artworkUrl,
            thumbnailUrl: thumbnailUrl,
            sourceId: sourceId,
            licenseType: licenseType,
            attributionString: attributionString,
            sourceUrl: sourceUrl,
            language: language,
            durationMs: durationMs,
            playCount: playCount,
            offlineAllowed: offlineAllowed,
            likedAt: likedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String artistName,
            required String artistId,
            required String albumName,
            required String albumId,
            Value<String?> artworkUrl = const Value.absent(),
            Value<String?> thumbnailUrl = const Value.absent(),
            required String sourceId,
            required String licenseType,
            required String attributionString,
            required String sourceUrl,
            required String language,
            required int durationMs,
            required int playCount,
            required bool offlineAllowed,
            Value<DateTime> likedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LikedTracksCompanion.insert(
            id: id,
            title: title,
            artistName: artistName,
            artistId: artistId,
            albumName: albumName,
            albumId: albumId,
            artworkUrl: artworkUrl,
            thumbnailUrl: thumbnailUrl,
            sourceId: sourceId,
            licenseType: licenseType,
            attributionString: attributionString,
            sourceUrl: sourceUrl,
            language: language,
            durationMs: durationMs,
            playCount: playCount,
            offlineAllowed: offlineAllowed,
            likedAt: likedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LikedTracksTableProcessedTableManager = ProcessedTableManager<
    _$AuxDatabase,
    $LikedTracksTable,
    LikedTrack,
    $$LikedTracksTableFilterComposer,
    $$LikedTracksTableOrderingComposer,
    $$LikedTracksTableAnnotationComposer,
    $$LikedTracksTableCreateCompanionBuilder,
    $$LikedTracksTableUpdateCompanionBuilder,
    (LikedTrack, BaseReferences<_$AuxDatabase, $LikedTracksTable, LikedTrack>),
    LikedTrack,
    PrefetchHooks Function()>;
typedef $$PlaylistsTableCreateCompanionBuilder = PlaylistsCompanion Function({
  Value<int> id,
  required String name,
  Value<String> description,
  Value<String?> coverUrl,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$PlaylistsTableUpdateCompanionBuilder = PlaylistsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> description,
  Value<String?> coverUrl,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$PlaylistsTableReferences
    extends BaseReferences<_$AuxDatabase, $PlaylistsTable, Playlist> {
  $$PlaylistsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaylistTracksTable, List<PlaylistTrack>>
      _playlistTracksRefsTable(_$AuxDatabase db) =>
          MultiTypedResultKey.fromTable(db.playlistTracks,
              aliasName: $_aliasNameGenerator(
                  db.playlists.id, db.playlistTracks.playlistId));

  $$PlaylistTracksTableProcessedTableManager get playlistTracksRefs {
    final manager = $$PlaylistTracksTableTableManager($_db, $_db.playlistTracks)
        .filter((f) => f.playlistId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_playlistTracksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PlaylistsTableFilterComposer
    extends Composer<_$AuxDatabase, $PlaylistsTable> {
  $$PlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverUrl => $composableBuilder(
      column: $table.coverUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> playlistTracksRefs(
      Expression<bool> Function($$PlaylistTracksTableFilterComposer f) f) {
    final $$PlaylistTracksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.playlistTracks,
        getReferencedColumn: (t) => t.playlistId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistTracksTableFilterComposer(
              $db: $db,
              $table: $db.playlistTracks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PlaylistsTableOrderingComposer
    extends Composer<_$AuxDatabase, $PlaylistsTable> {
  $$PlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverUrl => $composableBuilder(
      column: $table.coverUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PlaylistsTableAnnotationComposer
    extends Composer<_$AuxDatabase, $PlaylistsTable> {
  $$PlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> playlistTracksRefs<T extends Object>(
      Expression<T> Function($$PlaylistTracksTableAnnotationComposer a) f) {
    final $$PlaylistTracksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.playlistTracks,
        getReferencedColumn: (t) => t.playlistId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistTracksTableAnnotationComposer(
              $db: $db,
              $table: $db.playlistTracks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PlaylistsTableTableManager extends RootTableManager<
    _$AuxDatabase,
    $PlaylistsTable,
    Playlist,
    $$PlaylistsTableFilterComposer,
    $$PlaylistsTableOrderingComposer,
    $$PlaylistsTableAnnotationComposer,
    $$PlaylistsTableCreateCompanionBuilder,
    $$PlaylistsTableUpdateCompanionBuilder,
    (Playlist, $$PlaylistsTableReferences),
    Playlist,
    PrefetchHooks Function({bool playlistTracksRefs})> {
  $$PlaylistsTableTableManager(_$AuxDatabase db, $PlaylistsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> coverUrl = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              PlaylistsCompanion(
            id: id,
            name: name,
            description: description,
            coverUrl: coverUrl,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> description = const Value.absent(),
            Value<String?> coverUrl = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              PlaylistsCompanion.insert(
            id: id,
            name: name,
            description: description,
            coverUrl: coverUrl,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PlaylistsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({playlistTracksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistTracksRefs) db.playlistTracks
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistTracksRefs)
                    await $_getPrefetchedData<Playlist, $PlaylistsTable,
                            PlaylistTrack>(
                        currentTable: table,
                        referencedTable: $$PlaylistsTableReferences
                            ._playlistTracksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PlaylistsTableReferences(db, table, p0)
                                .playlistTracksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.playlistId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PlaylistsTableProcessedTableManager = ProcessedTableManager<
    _$AuxDatabase,
    $PlaylistsTable,
    Playlist,
    $$PlaylistsTableFilterComposer,
    $$PlaylistsTableOrderingComposer,
    $$PlaylistsTableAnnotationComposer,
    $$PlaylistsTableCreateCompanionBuilder,
    $$PlaylistsTableUpdateCompanionBuilder,
    (Playlist, $$PlaylistsTableReferences),
    Playlist,
    PrefetchHooks Function({bool playlistTracksRefs})>;
typedef $$PlaylistTracksTableCreateCompanionBuilder = PlaylistTracksCompanion
    Function({
  required int playlistId,
  required String trackId,
  required String title,
  required String artistName,
  Value<String?> artworkUrl,
  required String sourceId,
  required String licenseType,
  required String attributionString,
  required String trackJson,
  required int sortOrder,
  Value<DateTime> addedAt,
  Value<int> rowid,
});
typedef $$PlaylistTracksTableUpdateCompanionBuilder = PlaylistTracksCompanion
    Function({
  Value<int> playlistId,
  Value<String> trackId,
  Value<String> title,
  Value<String> artistName,
  Value<String?> artworkUrl,
  Value<String> sourceId,
  Value<String> licenseType,
  Value<String> attributionString,
  Value<String> trackJson,
  Value<int> sortOrder,
  Value<DateTime> addedAt,
  Value<int> rowid,
});

final class $$PlaylistTracksTableReferences
    extends BaseReferences<_$AuxDatabase, $PlaylistTracksTable, PlaylistTrack> {
  $$PlaylistTracksTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PlaylistsTable _playlistIdTable(_$AuxDatabase db) =>
      db.playlists.createAlias(
          $_aliasNameGenerator(db.playlistTracks.playlistId, db.playlists.id));

  $$PlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<int>('playlist_id')!;

    final manager = $$PlaylistsTableTableManager($_db, $_db.playlists)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PlaylistTracksTableFilterComposer
    extends Composer<_$AuxDatabase, $PlaylistTracksTable> {
  $$PlaylistTracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get trackId => $composableBuilder(
      column: $table.trackId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get artistName => $composableBuilder(
      column: $table.artistName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get artworkUrl => $composableBuilder(
      column: $table.artworkUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get licenseType => $composableBuilder(
      column: $table.licenseType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get attributionString => $composableBuilder(
      column: $table.attributionString,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trackJson => $composableBuilder(
      column: $table.trackJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));

  $$PlaylistsTableFilterComposer get playlistId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.playlistId,
        referencedTable: $db.playlists,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistsTableFilterComposer(
              $db: $db,
              $table: $db.playlists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlaylistTracksTableOrderingComposer
    extends Composer<_$AuxDatabase, $PlaylistTracksTable> {
  $$PlaylistTracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get trackId => $composableBuilder(
      column: $table.trackId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get artistName => $composableBuilder(
      column: $table.artistName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get artworkUrl => $composableBuilder(
      column: $table.artworkUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get licenseType => $composableBuilder(
      column: $table.licenseType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get attributionString => $composableBuilder(
      column: $table.attributionString,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trackJson => $composableBuilder(
      column: $table.trackJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));

  $$PlaylistsTableOrderingComposer get playlistId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.playlistId,
        referencedTable: $db.playlists,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistsTableOrderingComposer(
              $db: $db,
              $table: $db.playlists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlaylistTracksTableAnnotationComposer
    extends Composer<_$AuxDatabase, $PlaylistTracksTable> {
  $$PlaylistTracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artistName => $composableBuilder(
      column: $table.artistName, builder: (column) => column);

  GeneratedColumn<String> get artworkUrl => $composableBuilder(
      column: $table.artworkUrl, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get licenseType => $composableBuilder(
      column: $table.licenseType, builder: (column) => column);

  GeneratedColumn<String> get attributionString => $composableBuilder(
      column: $table.attributionString, builder: (column) => column);

  GeneratedColumn<String> get trackJson =>
      $composableBuilder(column: $table.trackJson, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$PlaylistsTableAnnotationComposer get playlistId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.playlistId,
        referencedTable: $db.playlists,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistsTableAnnotationComposer(
              $db: $db,
              $table: $db.playlists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlaylistTracksTableTableManager extends RootTableManager<
    _$AuxDatabase,
    $PlaylistTracksTable,
    PlaylistTrack,
    $$PlaylistTracksTableFilterComposer,
    $$PlaylistTracksTableOrderingComposer,
    $$PlaylistTracksTableAnnotationComposer,
    $$PlaylistTracksTableCreateCompanionBuilder,
    $$PlaylistTracksTableUpdateCompanionBuilder,
    (PlaylistTrack, $$PlaylistTracksTableReferences),
    PlaylistTrack,
    PrefetchHooks Function({bool playlistId})> {
  $$PlaylistTracksTableTableManager(
      _$AuxDatabase db, $PlaylistTracksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistTracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistTracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistTracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> playlistId = const Value.absent(),
            Value<String> trackId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> artistName = const Value.absent(),
            Value<String?> artworkUrl = const Value.absent(),
            Value<String> sourceId = const Value.absent(),
            Value<String> licenseType = const Value.absent(),
            Value<String> attributionString = const Value.absent(),
            Value<String> trackJson = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistTracksCompanion(
            playlistId: playlistId,
            trackId: trackId,
            title: title,
            artistName: artistName,
            artworkUrl: artworkUrl,
            sourceId: sourceId,
            licenseType: licenseType,
            attributionString: attributionString,
            trackJson: trackJson,
            sortOrder: sortOrder,
            addedAt: addedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int playlistId,
            required String trackId,
            required String title,
            required String artistName,
            Value<String?> artworkUrl = const Value.absent(),
            required String sourceId,
            required String licenseType,
            required String attributionString,
            required String trackJson,
            required int sortOrder,
            Value<DateTime> addedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistTracksCompanion.insert(
            playlistId: playlistId,
            trackId: trackId,
            title: title,
            artistName: artistName,
            artworkUrl: artworkUrl,
            sourceId: sourceId,
            licenseType: licenseType,
            attributionString: attributionString,
            trackJson: trackJson,
            sortOrder: sortOrder,
            addedAt: addedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PlaylistTracksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({playlistId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (playlistId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.playlistId,
                    referencedTable:
                        $$PlaylistTracksTableReferences._playlistIdTable(db),
                    referencedColumn:
                        $$PlaylistTracksTableReferences._playlistIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PlaylistTracksTableProcessedTableManager = ProcessedTableManager<
    _$AuxDatabase,
    $PlaylistTracksTable,
    PlaylistTrack,
    $$PlaylistTracksTableFilterComposer,
    $$PlaylistTracksTableOrderingComposer,
    $$PlaylistTracksTableAnnotationComposer,
    $$PlaylistTracksTableCreateCompanionBuilder,
    $$PlaylistTracksTableUpdateCompanionBuilder,
    (PlaylistTrack, $$PlaylistTracksTableReferences),
    PlaylistTrack,
    PrefetchHooks Function({bool playlistId})>;
typedef $$DownloadedFilesTableCreateCompanionBuilder = DownloadedFilesCompanion
    Function({
  required String trackId,
  required String localPath,
  required int sizeBytes,
  Value<DateTime> downloadedAt,
  Value<String?> title,
  Value<String?> artistName,
  Value<String?> artworkUrl,
  Value<int> rowid,
});
typedef $$DownloadedFilesTableUpdateCompanionBuilder = DownloadedFilesCompanion
    Function({
  Value<String> trackId,
  Value<String> localPath,
  Value<int> sizeBytes,
  Value<DateTime> downloadedAt,
  Value<String?> title,
  Value<String?> artistName,
  Value<String?> artworkUrl,
  Value<int> rowid,
});

class $$DownloadedFilesTableFilterComposer
    extends Composer<_$AuxDatabase, $DownloadedFilesTable> {
  $$DownloadedFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get trackId => $composableBuilder(
      column: $table.trackId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get artistName => $composableBuilder(
      column: $table.artistName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get artworkUrl => $composableBuilder(
      column: $table.artworkUrl, builder: (column) => ColumnFilters(column));
}

class $$DownloadedFilesTableOrderingComposer
    extends Composer<_$AuxDatabase, $DownloadedFilesTable> {
  $$DownloadedFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get trackId => $composableBuilder(
      column: $table.trackId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get artistName => $composableBuilder(
      column: $table.artistName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get artworkUrl => $composableBuilder(
      column: $table.artworkUrl, builder: (column) => ColumnOrderings(column));
}

class $$DownloadedFilesTableAnnotationComposer
    extends Composer<_$AuxDatabase, $DownloadedFilesTable> {
  $$DownloadedFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artistName => $composableBuilder(
      column: $table.artistName, builder: (column) => column);

  GeneratedColumn<String> get artworkUrl => $composableBuilder(
      column: $table.artworkUrl, builder: (column) => column);
}

class $$DownloadedFilesTableTableManager extends RootTableManager<
    _$AuxDatabase,
    $DownloadedFilesTable,
    DownloadedFile,
    $$DownloadedFilesTableFilterComposer,
    $$DownloadedFilesTableOrderingComposer,
    $$DownloadedFilesTableAnnotationComposer,
    $$DownloadedFilesTableCreateCompanionBuilder,
    $$DownloadedFilesTableUpdateCompanionBuilder,
    (
      DownloadedFile,
      BaseReferences<_$AuxDatabase, $DownloadedFilesTable, DownloadedFile>
    ),
    DownloadedFile,
    PrefetchHooks Function()> {
  $$DownloadedFilesTableTableManager(
      _$AuxDatabase db, $DownloadedFilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadedFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadedFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadedFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> trackId = const Value.absent(),
            Value<String> localPath = const Value.absent(),
            Value<int> sizeBytes = const Value.absent(),
            Value<DateTime> downloadedAt = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> artistName = const Value.absent(),
            Value<String?> artworkUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadedFilesCompanion(
            trackId: trackId,
            localPath: localPath,
            sizeBytes: sizeBytes,
            downloadedAt: downloadedAt,
            title: title,
            artistName: artistName,
            artworkUrl: artworkUrl,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String trackId,
            required String localPath,
            required int sizeBytes,
            Value<DateTime> downloadedAt = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> artistName = const Value.absent(),
            Value<String?> artworkUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadedFilesCompanion.insert(
            trackId: trackId,
            localPath: localPath,
            sizeBytes: sizeBytes,
            downloadedAt: downloadedAt,
            title: title,
            artistName: artistName,
            artworkUrl: artworkUrl,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DownloadedFilesTableProcessedTableManager = ProcessedTableManager<
    _$AuxDatabase,
    $DownloadedFilesTable,
    DownloadedFile,
    $$DownloadedFilesTableFilterComposer,
    $$DownloadedFilesTableOrderingComposer,
    $$DownloadedFilesTableAnnotationComposer,
    $$DownloadedFilesTableCreateCompanionBuilder,
    $$DownloadedFilesTableUpdateCompanionBuilder,
    (
      DownloadedFile,
      BaseReferences<_$AuxDatabase, $DownloadedFilesTable, DownloadedFile>
    ),
    DownloadedFile,
    PrefetchHooks Function()>;
typedef $$RecentSearchesTableCreateCompanionBuilder = RecentSearchesCompanion
    Function({
  required String query,
  Value<DateTime> searchedAt,
  Value<int> rowid,
});
typedef $$RecentSearchesTableUpdateCompanionBuilder = RecentSearchesCompanion
    Function({
  Value<String> query,
  Value<DateTime> searchedAt,
  Value<int> rowid,
});

class $$RecentSearchesTableFilterComposer
    extends Composer<_$AuxDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get query => $composableBuilder(
      column: $table.query, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get searchedAt => $composableBuilder(
      column: $table.searchedAt, builder: (column) => ColumnFilters(column));
}

class $$RecentSearchesTableOrderingComposer
    extends Composer<_$AuxDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get query => $composableBuilder(
      column: $table.query, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get searchedAt => $composableBuilder(
      column: $table.searchedAt, builder: (column) => ColumnOrderings(column));
}

class $$RecentSearchesTableAnnotationComposer
    extends Composer<_$AuxDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<DateTime> get searchedAt => $composableBuilder(
      column: $table.searchedAt, builder: (column) => column);
}

class $$RecentSearchesTableTableManager extends RootTableManager<
    _$AuxDatabase,
    $RecentSearchesTable,
    RecentSearche,
    $$RecentSearchesTableFilterComposer,
    $$RecentSearchesTableOrderingComposer,
    $$RecentSearchesTableAnnotationComposer,
    $$RecentSearchesTableCreateCompanionBuilder,
    $$RecentSearchesTableUpdateCompanionBuilder,
    (
      RecentSearche,
      BaseReferences<_$AuxDatabase, $RecentSearchesTable, RecentSearche>
    ),
    RecentSearche,
    PrefetchHooks Function()> {
  $$RecentSearchesTableTableManager(
      _$AuxDatabase db, $RecentSearchesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentSearchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentSearchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentSearchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> query = const Value.absent(),
            Value<DateTime> searchedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecentSearchesCompanion(
            query: query,
            searchedAt: searchedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String query,
            Value<DateTime> searchedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecentSearchesCompanion.insert(
            query: query,
            searchedAt: searchedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RecentSearchesTableProcessedTableManager = ProcessedTableManager<
    _$AuxDatabase,
    $RecentSearchesTable,
    RecentSearche,
    $$RecentSearchesTableFilterComposer,
    $$RecentSearchesTableOrderingComposer,
    $$RecentSearchesTableAnnotationComposer,
    $$RecentSearchesTableCreateCompanionBuilder,
    $$RecentSearchesTableUpdateCompanionBuilder,
    (
      RecentSearche,
      BaseReferences<_$AuxDatabase, $RecentSearchesTable, RecentSearche>
    ),
    RecentSearche,
    PrefetchHooks Function()>;
typedef $$SubscribedPodcastsTableCreateCompanionBuilder
    = SubscribedPodcastsCompanion Function({
  required String id,
  required String title,
  required String author,
  required String description,
  Value<String?> artworkUrl,
  required String feedUrl,
  Value<DateTime> subscribedAt,
  Value<int> rowid,
});
typedef $$SubscribedPodcastsTableUpdateCompanionBuilder
    = SubscribedPodcastsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> author,
  Value<String> description,
  Value<String?> artworkUrl,
  Value<String> feedUrl,
  Value<DateTime> subscribedAt,
  Value<int> rowid,
});

final class $$SubscribedPodcastsTableReferences extends BaseReferences<
    _$AuxDatabase, $SubscribedPodcastsTable, SubscribedPodcast> {
  $$SubscribedPodcastsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PodcastEpisodesProgressTable,
      List<PodcastEpisodesProgressData>> _podcastEpisodesProgressRefsTable(
          _$AuxDatabase db) =>
      MultiTypedResultKey.fromTable(db.podcastEpisodesProgress,
          aliasName: $_aliasNameGenerator(
              db.subscribedPodcasts.id, db.podcastEpisodesProgress.podcastId));

  $$PodcastEpisodesProgressTableProcessedTableManager
      get podcastEpisodesProgressRefs {
    final manager = $$PodcastEpisodesProgressTableTableManager(
            $_db, $_db.podcastEpisodesProgress)
        .filter((f) => f.podcastId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_podcastEpisodesProgressRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SubscribedPodcastsTableFilterComposer
    extends Composer<_$AuxDatabase, $SubscribedPodcastsTable> {
  $$SubscribedPodcastsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get artworkUrl => $composableBuilder(
      column: $table.artworkUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get feedUrl => $composableBuilder(
      column: $table.feedUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get subscribedAt => $composableBuilder(
      column: $table.subscribedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> podcastEpisodesProgressRefs(
      Expression<bool> Function($$PodcastEpisodesProgressTableFilterComposer f)
          f) {
    final $$PodcastEpisodesProgressTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.podcastEpisodesProgress,
            getReferencedColumn: (t) => t.podcastId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PodcastEpisodesProgressTableFilterComposer(
                  $db: $db,
                  $table: $db.podcastEpisodesProgress,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SubscribedPodcastsTableOrderingComposer
    extends Composer<_$AuxDatabase, $SubscribedPodcastsTable> {
  $$SubscribedPodcastsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get artworkUrl => $composableBuilder(
      column: $table.artworkUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get feedUrl => $composableBuilder(
      column: $table.feedUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get subscribedAt => $composableBuilder(
      column: $table.subscribedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$SubscribedPodcastsTableAnnotationComposer
    extends Composer<_$AuxDatabase, $SubscribedPodcastsTable> {
  $$SubscribedPodcastsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get artworkUrl => $composableBuilder(
      column: $table.artworkUrl, builder: (column) => column);

  GeneratedColumn<String> get feedUrl =>
      $composableBuilder(column: $table.feedUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get subscribedAt => $composableBuilder(
      column: $table.subscribedAt, builder: (column) => column);

  Expression<T> podcastEpisodesProgressRefs<T extends Object>(
      Expression<T> Function($$PodcastEpisodesProgressTableAnnotationComposer a)
          f) {
    final $$PodcastEpisodesProgressTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.podcastEpisodesProgress,
            getReferencedColumn: (t) => t.podcastId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PodcastEpisodesProgressTableAnnotationComposer(
                  $db: $db,
                  $table: $db.podcastEpisodesProgress,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SubscribedPodcastsTableTableManager extends RootTableManager<
    _$AuxDatabase,
    $SubscribedPodcastsTable,
    SubscribedPodcast,
    $$SubscribedPodcastsTableFilterComposer,
    $$SubscribedPodcastsTableOrderingComposer,
    $$SubscribedPodcastsTableAnnotationComposer,
    $$SubscribedPodcastsTableCreateCompanionBuilder,
    $$SubscribedPodcastsTableUpdateCompanionBuilder,
    (SubscribedPodcast, $$SubscribedPodcastsTableReferences),
    SubscribedPodcast,
    PrefetchHooks Function({bool podcastEpisodesProgressRefs})> {
  $$SubscribedPodcastsTableTableManager(
      _$AuxDatabase db, $SubscribedPodcastsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscribedPodcastsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscribedPodcastsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscribedPodcastsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> author = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> artworkUrl = const Value.absent(),
            Value<String> feedUrl = const Value.absent(),
            Value<DateTime> subscribedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubscribedPodcastsCompanion(
            id: id,
            title: title,
            author: author,
            description: description,
            artworkUrl: artworkUrl,
            feedUrl: feedUrl,
            subscribedAt: subscribedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String author,
            required String description,
            Value<String?> artworkUrl = const Value.absent(),
            required String feedUrl,
            Value<DateTime> subscribedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubscribedPodcastsCompanion.insert(
            id: id,
            title: title,
            author: author,
            description: description,
            artworkUrl: artworkUrl,
            feedUrl: feedUrl,
            subscribedAt: subscribedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SubscribedPodcastsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({podcastEpisodesProgressRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (podcastEpisodesProgressRefs) db.podcastEpisodesProgress
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (podcastEpisodesProgressRefs)
                    await $_getPrefetchedData<
                            SubscribedPodcast,
                            $SubscribedPodcastsTable,
                            PodcastEpisodesProgressData>(
                        currentTable: table,
                        referencedTable: $$SubscribedPodcastsTableReferences
                            ._podcastEpisodesProgressRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SubscribedPodcastsTableReferences(db, table, p0)
                                .podcastEpisodesProgressRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.podcastId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SubscribedPodcastsTableProcessedTableManager = ProcessedTableManager<
    _$AuxDatabase,
    $SubscribedPodcastsTable,
    SubscribedPodcast,
    $$SubscribedPodcastsTableFilterComposer,
    $$SubscribedPodcastsTableOrderingComposer,
    $$SubscribedPodcastsTableAnnotationComposer,
    $$SubscribedPodcastsTableCreateCompanionBuilder,
    $$SubscribedPodcastsTableUpdateCompanionBuilder,
    (SubscribedPodcast, $$SubscribedPodcastsTableReferences),
    SubscribedPodcast,
    PrefetchHooks Function({bool podcastEpisodesProgressRefs})>;
typedef $$PodcastEpisodesProgressTableCreateCompanionBuilder
    = PodcastEpisodesProgressCompanion Function({
  required String episodeId,
  required String podcastId,
  Value<int> progressMs,
  required int durationMs,
  Value<bool> isCompleted,
  Value<DateTime> lastListenedAt,
  Value<int> rowid,
});
typedef $$PodcastEpisodesProgressTableUpdateCompanionBuilder
    = PodcastEpisodesProgressCompanion Function({
  Value<String> episodeId,
  Value<String> podcastId,
  Value<int> progressMs,
  Value<int> durationMs,
  Value<bool> isCompleted,
  Value<DateTime> lastListenedAt,
  Value<int> rowid,
});

final class $$PodcastEpisodesProgressTableReferences extends BaseReferences<
    _$AuxDatabase, $PodcastEpisodesProgressTable, PodcastEpisodesProgressData> {
  $$PodcastEpisodesProgressTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SubscribedPodcastsTable _podcastIdTable(_$AuxDatabase db) =>
      db.subscribedPodcasts.createAlias($_aliasNameGenerator(
          db.podcastEpisodesProgress.podcastId, db.subscribedPodcasts.id));

  $$SubscribedPodcastsTableProcessedTableManager get podcastId {
    final $_column = $_itemColumn<String>('podcast_id')!;

    final manager =
        $$SubscribedPodcastsTableTableManager($_db, $_db.subscribedPodcasts)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_podcastIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PodcastEpisodesProgressTableFilterComposer
    extends Composer<_$AuxDatabase, $PodcastEpisodesProgressTable> {
  $$PodcastEpisodesProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get episodeId => $composableBuilder(
      column: $table.episodeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get progressMs => $composableBuilder(
      column: $table.progressMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastListenedAt => $composableBuilder(
      column: $table.lastListenedAt,
      builder: (column) => ColumnFilters(column));

  $$SubscribedPodcastsTableFilterComposer get podcastId {
    final $$SubscribedPodcastsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.podcastId,
        referencedTable: $db.subscribedPodcasts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubscribedPodcastsTableFilterComposer(
              $db: $db,
              $table: $db.subscribedPodcasts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PodcastEpisodesProgressTableOrderingComposer
    extends Composer<_$AuxDatabase, $PodcastEpisodesProgressTable> {
  $$PodcastEpisodesProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get episodeId => $composableBuilder(
      column: $table.episodeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get progressMs => $composableBuilder(
      column: $table.progressMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastListenedAt => $composableBuilder(
      column: $table.lastListenedAt,
      builder: (column) => ColumnOrderings(column));

  $$SubscribedPodcastsTableOrderingComposer get podcastId {
    final $$SubscribedPodcastsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.podcastId,
        referencedTable: $db.subscribedPodcasts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubscribedPodcastsTableOrderingComposer(
              $db: $db,
              $table: $db.subscribedPodcasts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PodcastEpisodesProgressTableAnnotationComposer
    extends Composer<_$AuxDatabase, $PodcastEpisodesProgressTable> {
  $$PodcastEpisodesProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get episodeId =>
      $composableBuilder(column: $table.episodeId, builder: (column) => column);

  GeneratedColumn<int> get progressMs => $composableBuilder(
      column: $table.progressMs, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get lastListenedAt => $composableBuilder(
      column: $table.lastListenedAt, builder: (column) => column);

  $$SubscribedPodcastsTableAnnotationComposer get podcastId {
    final $$SubscribedPodcastsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.podcastId,
            referencedTable: $db.subscribedPodcasts,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SubscribedPodcastsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.subscribedPodcasts,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$PodcastEpisodesProgressTableTableManager extends RootTableManager<
    _$AuxDatabase,
    $PodcastEpisodesProgressTable,
    PodcastEpisodesProgressData,
    $$PodcastEpisodesProgressTableFilterComposer,
    $$PodcastEpisodesProgressTableOrderingComposer,
    $$PodcastEpisodesProgressTableAnnotationComposer,
    $$PodcastEpisodesProgressTableCreateCompanionBuilder,
    $$PodcastEpisodesProgressTableUpdateCompanionBuilder,
    (PodcastEpisodesProgressData, $$PodcastEpisodesProgressTableReferences),
    PodcastEpisodesProgressData,
    PrefetchHooks Function({bool podcastId})> {
  $$PodcastEpisodesProgressTableTableManager(
      _$AuxDatabase db, $PodcastEpisodesProgressTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PodcastEpisodesProgressTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$PodcastEpisodesProgressTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PodcastEpisodesProgressTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> episodeId = const Value.absent(),
            Value<String> podcastId = const Value.absent(),
            Value<int> progressMs = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime> lastListenedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PodcastEpisodesProgressCompanion(
            episodeId: episodeId,
            podcastId: podcastId,
            progressMs: progressMs,
            durationMs: durationMs,
            isCompleted: isCompleted,
            lastListenedAt: lastListenedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String episodeId,
            required String podcastId,
            Value<int> progressMs = const Value.absent(),
            required int durationMs,
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime> lastListenedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PodcastEpisodesProgressCompanion.insert(
            episodeId: episodeId,
            podcastId: podcastId,
            progressMs: progressMs,
            durationMs: durationMs,
            isCompleted: isCompleted,
            lastListenedAt: lastListenedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PodcastEpisodesProgressTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({podcastId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (podcastId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.podcastId,
                    referencedTable: $$PodcastEpisodesProgressTableReferences
                        ._podcastIdTable(db),
                    referencedColumn: $$PodcastEpisodesProgressTableReferences
                        ._podcastIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PodcastEpisodesProgressTableProcessedTableManager
    = ProcessedTableManager<
        _$AuxDatabase,
        $PodcastEpisodesProgressTable,
        PodcastEpisodesProgressData,
        $$PodcastEpisodesProgressTableFilterComposer,
        $$PodcastEpisodesProgressTableOrderingComposer,
        $$PodcastEpisodesProgressTableAnnotationComposer,
        $$PodcastEpisodesProgressTableCreateCompanionBuilder,
        $$PodcastEpisodesProgressTableUpdateCompanionBuilder,
        (PodcastEpisodesProgressData, $$PodcastEpisodesProgressTableReferences),
        PodcastEpisodesProgressData,
        PrefetchHooks Function({bool podcastId})>;

class $AuxDatabaseManager {
  final _$AuxDatabase _db;
  $AuxDatabaseManager(this._db);
  $$LikedTracksTableTableManager get likedTracks =>
      $$LikedTracksTableTableManager(_db, _db.likedTracks);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db, _db.playlists);
  $$PlaylistTracksTableTableManager get playlistTracks =>
      $$PlaylistTracksTableTableManager(_db, _db.playlistTracks);
  $$DownloadedFilesTableTableManager get downloadedFiles =>
      $$DownloadedFilesTableTableManager(_db, _db.downloadedFiles);
  $$RecentSearchesTableTableManager get recentSearches =>
      $$RecentSearchesTableTableManager(_db, _db.recentSearches);
  $$SubscribedPodcastsTableTableManager get subscribedPodcasts =>
      $$SubscribedPodcastsTableTableManager(_db, _db.subscribedPodcasts);
  $$PodcastEpisodesProgressTableTableManager get podcastEpisodesProgress =>
      $$PodcastEpisodesProgressTableTableManager(
          _db, _db.podcastEpisodesProgress);
}
