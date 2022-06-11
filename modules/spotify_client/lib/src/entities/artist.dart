import 'package:json_annotation/json_annotation.dart';

part 'artist.g.dart';

@JsonSerializable()
class Artist {
  const Artist({
    required this.uri,
    required this.name,
  });

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);

  @JsonKey(defaultValue: '')
  final String uri;

  @JsonKey(defaultValue: '')
  final String name;

  Map<String, dynamic> get toJson => _$ArtistToJson(this);
}
