import 'package:json_annotation/json_annotation.dart';

part 'album.g.dart';

@JsonSerializable()
class Album {
  const Album({
    required this.uri,
    required this.name,
  });

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);

  @JsonKey(defaultValue: '')
  final String uri;

  @JsonKey(defaultValue: '')
  final String name;

  Map<String, dynamic> get toJson => _$AlbumToJson(this);
}
