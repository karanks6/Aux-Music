import 'package:freezed_annotation/freezed_annotation.dart';
import 'track.dart';

part 'podcast.freezed.dart';
part 'podcast.g.dart';

@freezed
class Podcast with _$Podcast {
  const factory Podcast({
    required String id,
    required String title,
    required String author,
    required String description,
    String? artworkUrl,
    required String feedUrl,
  }) = _Podcast;

  factory Podcast.fromJson(Map<String, dynamic> json) => _$PodcastFromJson(json);
}

@freezed
class PodcastEpisode with _$PodcastEpisode {
  const factory PodcastEpisode({
    required String id,
    required String podcastId,
    required String title,
    required String description,
    required String streamUrl,
    required DateTime publishedAt,
    required int durationMs,
    String? artworkUrl,
  }) = _PodcastEpisode;

  const PodcastEpisode._();

  factory PodcastEpisode.fromJson(Map<String, dynamic> json) => _$PodcastEpisodeFromJson(json);

  /// Convert a PodcastEpisode into a standard Track for the audio engine
  Track toTrack({required String podcastTitle, required String podcastAuthor}) {
    return Track(
      id: id,
      title: title,
      artistName: podcastTitle,
      artistId: podcastId,
      albumName: 'Podcast Episode',
      albumId: podcastId,
      artworkUrl: artworkUrl,
      sourceId: 'podcast',
      sourceUrl: streamUrl,
      streamUrl: streamUrl,
      durationMs: durationMs,
    );
  }
}
