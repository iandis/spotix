import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'content_item.g.dart';

@JsonSerializable()
class ContentItem extends Equatable {
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

  final String imageUri;

  @JsonKey(name: 'playable')
  final bool isPlayable;

  final bool hasChildren;

  bool get hasImageUrl => imageUri.startsWith('https');

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
