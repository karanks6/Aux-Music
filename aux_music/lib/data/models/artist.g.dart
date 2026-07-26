// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ArtistImpl _$$ArtistImplFromJson(Map<String, dynamic> json) => _$ArtistImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      sourceId: json['sourceId'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      bannerUrl: json['bannerUrl'] as String?,
      bio: json['bio'] as String? ?? '',
      location: json['location'] as String? ?? '',
      followerCount: (json['followerCount'] as num?)?.toInt() ?? 0,
      trackCount: (json['trackCount'] as num?)?.toInt() ?? 0,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isFollowed: json['isFollowed'] as bool? ?? false,
      websiteUrl: json['websiteUrl'] as String?,
      musicBrainzId: json['musicBrainzId'] as String?,
    );

Map<String, dynamic> _$$ArtistImplToJson(_$ArtistImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sourceId': instance.sourceId,
      'avatarUrl': instance.avatarUrl,
      'bannerUrl': instance.bannerUrl,
      'bio': instance.bio,
      'location': instance.location,
      'followerCount': instance.followerCount,
      'trackCount': instance.trackCount,
      'genres': instance.genres,
      'isFollowed': instance.isFollowed,
      'websiteUrl': instance.websiteUrl,
      'musicBrainzId': instance.musicBrainzId,
    };

_$AlbumImpl _$$AlbumImplFromJson(Map<String, dynamic> json) => _$AlbumImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      artistId: json['artistId'] as String,
      artistName: json['artistName'] as String,
      sourceId: json['sourceId'] as String,
      artworkUrl: json['artworkUrl'] as String?,
      description: json['description'] as String? ?? '',
      tracks: (json['tracks'] as List<dynamic>?)
              ?.map((e) => Track.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      trackCount: (json['trackCount'] as num?)?.toInt() ?? 0,
      releaseYear: (json['releaseYear'] as num?)?.toInt(),
      licenseType:
          $enumDecodeNullable(_$LicenseTypeEnumMap, json['licenseType']) ??
              LicenseType.unknown,
      attributionString: json['attributionString'] as String? ?? '',
    );

Map<String, dynamic> _$$AlbumImplToJson(_$AlbumImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artistId': instance.artistId,
      'artistName': instance.artistName,
      'sourceId': instance.sourceId,
      'artworkUrl': instance.artworkUrl,
      'description': instance.description,
      'tracks': instance.tracks,
      'trackCount': instance.trackCount,
      'releaseYear': instance.releaseYear,
      'licenseType': _$LicenseTypeEnumMap[instance.licenseType]!,
      'attributionString': instance.attributionString,
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
