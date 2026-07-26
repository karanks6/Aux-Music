// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PodcastImpl _$$PodcastImplFromJson(Map<String, dynamic> json) =>
    _$PodcastImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      description: json['description'] as String,
      artworkUrl: json['artworkUrl'] as String?,
      feedUrl: json['feedUrl'] as String,
    );

Map<String, dynamic> _$$PodcastImplToJson(_$PodcastImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'author': instance.author,
      'description': instance.description,
      'artworkUrl': instance.artworkUrl,
      'feedUrl': instance.feedUrl,
    };

_$PodcastEpisodeImpl _$$PodcastEpisodeImplFromJson(Map<String, dynamic> json) =>
    _$PodcastEpisodeImpl(
      id: json['id'] as String,
      podcastId: json['podcastId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      streamUrl: json['streamUrl'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      durationMs: (json['durationMs'] as num).toInt(),
      artworkUrl: json['artworkUrl'] as String?,
    );

Map<String, dynamic> _$$PodcastEpisodeImplToJson(
        _$PodcastEpisodeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'podcastId': instance.podcastId,
      'title': instance.title,
      'description': instance.description,
      'streamUrl': instance.streamUrl,
      'publishedAt': instance.publishedAt.toIso8601String(),
      'durationMs': instance.durationMs,
      'artworkUrl': instance.artworkUrl,
    };
