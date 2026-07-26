// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrackImpl _$$TrackImplFromJson(Map<String, dynamic> json) => _$TrackImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      artistName: json['artistName'] as String,
      artistId: json['artistId'] as String? ?? '',
      albumName: json['albumName'] as String? ?? '',
      albumId: json['albumId'] as String? ?? '',
      artworkUrl: json['artworkUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      sourceId: json['sourceId'] as String,
      licenseType:
          $enumDecodeNullable(_$LicenseTypeEnumMap, json['licenseType']) ??
              LicenseType.unknown,
      attributionString: json['attributionString'] as String? ?? '',
      sourceUrl: json['sourceUrl'] as String? ?? '',
      language: json['language'] as String? ?? 'en',
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
      playCount: (json['playCount'] as num?)?.toInt() ?? 0,
      offlineAllowed: json['offlineAllowed'] as bool? ?? true,
      streamUrl: json['streamUrl'] as String?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      isLiked: json['isLiked'] as bool? ?? false,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      localPath: json['localPath'] as String?,
      bpm: (json['bpm'] as num?)?.toDouble(),
      waveformData: (json['waveformData'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      addedAt: json['addedAt'] == null
          ? null
          : DateTime.parse(json['addedAt'] as String),
      lastPlayedAt: json['lastPlayedAt'] == null
          ? null
          : DateTime.parse(json['lastPlayedAt'] as String),
    );

Map<String, dynamic> _$$TrackImplToJson(_$TrackImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artistName': instance.artistName,
      'artistId': instance.artistId,
      'albumName': instance.albumName,
      'albumId': instance.albumId,
      'artworkUrl': instance.artworkUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'sourceId': instance.sourceId,
      'licenseType': _$LicenseTypeEnumMap[instance.licenseType]!,
      'attributionString': instance.attributionString,
      'sourceUrl': instance.sourceUrl,
      'language': instance.language,
      'durationMs': instance.durationMs,
      'playCount': instance.playCount,
      'offlineAllowed': instance.offlineAllowed,
      'streamUrl': instance.streamUrl,
      'genres': instance.genres,
      'tags': instance.tags,
      'isLiked': instance.isLiked,
      'isDownloaded': instance.isDownloaded,
      'localPath': instance.localPath,
      'bpm': instance.bpm,
      'waveformData': instance.waveformData,
      'addedAt': instance.addedAt?.toIso8601String(),
      'lastPlayedAt': instance.lastPlayedAt?.toIso8601String(),
    };

const _$LicenseTypeEnumMap = {
  LicenseType.cc0: 'CC0',
  LicenseType.ccBy: 'CC-BY',
  LicenseType.ccBySa: 'CC-BY-SA',
  LicenseType.ccByNd: 'CC-BY-ND',
  LicenseType.ccByNc: 'CC-BY-NC',
  LicenseType.ccByNcSa: 'CC-BY-NC-SA',
  LicenseType.ccByNcNd: 'CC-BY-NC-ND',
  LicenseType.publicDomain: 'PUBLIC_DOMAIN',
  LicenseType.custom: 'CUSTOM',
  LicenseType.unknown: 'UNKNOWN',
};
