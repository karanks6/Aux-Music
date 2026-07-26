// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaylistCollaboratorImpl _$$PlaylistCollaboratorImplFromJson(
        Map<String, dynamic> json) =>
    _$PlaylistCollaboratorImpl(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      role: $enumDecodeNullable(_$PlaylistRoleEnumMap, json['role']) ??
          PlaylistRole.viewOnly,
    );

Map<String, dynamic> _$$PlaylistCollaboratorImplToJson(
        _$PlaylistCollaboratorImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'role': _$PlaylistRoleEnumMap[instance.role]!,
    };

const _$PlaylistRoleEnumMap = {
  PlaylistRole.owner: 'owner',
  PlaylistRole.addRemove: 'add_remove',
  PlaylistRole.addOnly: 'add_only',
  PlaylistRole.viewOnly: 'view_only',
};

_$PlaylistActivityImpl _$$PlaylistActivityImplFromJson(
        Map<String, dynamic> json) =>
    _$PlaylistActivityImpl(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      action: json['action'] as String,
      trackTitle: json['trackTitle'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$PlaylistActivityImplToJson(
        _$PlaylistActivityImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'displayName': instance.displayName,
      'action': instance.action,
      'trackTitle': instance.trackTitle,
      'timestamp': instance.timestamp.toIso8601String(),
    };

_$PlaylistImpl _$$PlaylistImplFromJson(Map<String, dynamic> json) =>
    _$PlaylistImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['ownerId'] as String,
      ownerName: json['ownerName'] as String?,
      description: json['description'] as String?,
      coverArtUrl: json['coverArtUrl'] as String?,
      mosaicArts: (json['mosaicArts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tracks: (json['tracks'] as List<dynamic>?)
              ?.map((e) => Track.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      trackCount: (json['trackCount'] as num?)?.toInt() ?? 0,
      collaborators: (json['collaborators'] as List<dynamic>?)
              ?.map((e) =>
                  PlaylistCollaborator.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      activityFeed: (json['activityFeed'] as List<dynamic>?)
              ?.map((e) => PlaylistActivity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isCollaborative: json['isCollaborative'] as bool? ?? false,
      isPublic: json['isPublic'] as bool? ?? false,
      firestoreId: json['firestoreId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      lastPlayedAt: json['lastPlayedAt'] == null
          ? null
          : DateTime.parse(json['lastPlayedAt'] as String),
    );

Map<String, dynamic> _$$PlaylistImplToJson(_$PlaylistImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ownerId': instance.ownerId,
      'ownerName': instance.ownerName,
      'description': instance.description,
      'coverArtUrl': instance.coverArtUrl,
      'mosaicArts': instance.mosaicArts,
      'tracks': instance.tracks,
      'trackCount': instance.trackCount,
      'collaborators': instance.collaborators,
      'activityFeed': instance.activityFeed,
      'isCollaborative': instance.isCollaborative,
      'isPublic': instance.isPublic,
      'firestoreId': instance.firestoreId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'lastPlayedAt': instance.lastPlayedAt?.toIso8601String(),
    };
