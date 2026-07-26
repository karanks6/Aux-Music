import 'package:freezed_annotation/freezed_annotation.dart';
import 'track.dart';

part 'playlist.freezed.dart';
part 'playlist.g.dart';

enum PlaylistRole {
  @JsonValue('owner') owner,
  @JsonValue('add_remove') addRemove,
  @JsonValue('add_only') addOnly,
  @JsonValue('view_only') viewOnly,
}

@freezed
abstract class PlaylistCollaborator with _$PlaylistCollaborator {
  const factory PlaylistCollaborator({
    required String userId,
    required String displayName,
    String? avatarUrl,
    @Default(PlaylistRole.viewOnly) PlaylistRole role,
  }) = _PlaylistCollaborator;

  factory PlaylistCollaborator.fromJson(Map<String, dynamic> json) =>
      _$PlaylistCollaboratorFromJson(json);
}

@freezed
abstract class PlaylistActivity with _$PlaylistActivity {
  const factory PlaylistActivity({
    required String userId,
    required String displayName,
    required String action, // 'added' | 'removed'
    required String trackTitle,
    required DateTime timestamp,
  }) = _PlaylistActivity;

  factory PlaylistActivity.fromJson(Map<String, dynamic> json) =>
      _$PlaylistActivityFromJson(json);
}

@freezed
abstract class Playlist with _$Playlist {
  const factory Playlist({
    required String id,
    required String name,
    required String ownerId,
    String? ownerName,
    String? description,

    /// Custom cover art URL, or null if using auto-generated mosaic
    String? coverArtUrl,

    /// The 4 track artwork URLs used for the mosaic (auto-generated)
    @Default([]) List<String> mosaicArts,

    @Default([]) List<Track> tracks,
    @Default(0) int trackCount,

    /// Collaborators (empty for solo playlists)
    @Default([]) List<PlaylistCollaborator> collaborators,

    /// Activity feed — who added/removed what
    @Default([]) List<PlaylistActivity> activityFeed,

    @Default(false) bool isCollaborative,
    @Default(false) bool isPublic,

    /// Firestore document ID (null for local-only playlists)
    String? firestoreId,

    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastPlayedAt,
  }) = _Playlist;

  factory Playlist.fromJson(Map<String, dynamic> json) =>
      _$PlaylistFromJson(json);
}
