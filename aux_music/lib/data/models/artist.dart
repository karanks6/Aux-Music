import 'package:freezed_annotation/freezed_annotation.dart';
import 'track.dart';
import 'license_type.dart';

part 'artist.freezed.dart';
part 'artist.g.dart';

@freezed
abstract class Artist with _$Artist {
  const factory Artist({
    required String id,
    required String name,
    required String sourceId,
    String? avatarUrl,
    String? bannerUrl,
    @Default('') String bio,
    @Default('') String location,
    @Default(0) int followerCount,
    @Default(0) int trackCount,
    @Default([]) List<String> genres,
    @Default(false) bool isFollowed,
    String? websiteUrl,
    String? musicBrainzId,
  }) = _Artist;

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);
}

@freezed
abstract class Album with _$Album {
  const factory Album({
    required String id,
    required String title,
    required String artistId,
    required String artistName,
    required String sourceId,
    String? artworkUrl,
    @Default('') String description,
    @Default([]) List<Track> tracks,
    @Default(0) int trackCount,
    int? releaseYear,
    @Default(LicenseType.unknown) LicenseType licenseType,
    @Default('') String attributionString,
  }) = _Album;

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);
}
