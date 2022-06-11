import 'package:json_annotation/json_annotation.dart';
import 'package:spotify_client/src/entities/album.dart';
import 'package:spotify_client/src/entities/artist.dart';
import 'package:spotify_client/src/entities/map_converter.dart';

part 'track.g.dart';

@JsonSerializable()
class Track {
  const Track({
    required this.uri,
    required this.name,
    required this.duration,
    required this.imageUri,
    required this.album,
    required this.artist,
    required this.artists,
  });

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

  final String uri;

  final String name;

  final int duration;

  final String imageUri;

  @JsonKey(readValue: castFromNativeMap)
  final Album album;

  @JsonKey(readValue: castFromNativeMap)
  final Artist artist;

  @JsonKey(fromJson: _artistListFromJson)
  final List<Artist> artists;

  Map<String, dynamic> get toJson => _$TrackToJson(this);
}

List<Artist> _artistListFromJson(dynamic data) {
  final List<dynamic> artistList = data as List<dynamic>;
  return artistList.map<Artist>((dynamic e) {
    final Map<dynamic, dynamic> map = e as Map<dynamic, dynamic>;
    return Artist.fromJson(Map<String, dynamic>.from(map));
  }).toList(growable: false);
}
