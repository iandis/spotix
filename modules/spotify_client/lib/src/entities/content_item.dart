import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:spotify_client/src/entities/playback_image.dart';

part 'content_item.g.dart';

@JsonSerializable()
class ContentItem extends PlaybackImage with EquatableMixin {
  const ContentItem({
    required this.id,
    required this.uri,
    required this.title,
    required this.subtitle,
    required this.imageUri,
    required this.isPlayable,
    required this.hasChildren,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) =>
      _$ContentItemFromJson(json);

  final String id;

  final String uri;

  final String title;

  final String subtitle;

  @override
  final String imageUri;

  @JsonKey(name: 'playable')
  final bool isPlayable;

  final bool hasChildren;

  Map<String, dynamic> get toJson => _$ContentItemToJson(this);

  @override
  List<Object?> get props => <Object?>[
        id,
        uri,
        title,
        subtitle,
        imageUri,
        isPlayable,
        hasChildren,
      ];
}
