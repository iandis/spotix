// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentItem _$ContentItemFromJson(Map<String, dynamic> json) => ContentItem(
      id: json['id'] as String,
      uri: json['uri'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imageUri: json['imageUri'] as String,
      isPlayable: json['playable'] as bool,
      hasChildren: json['hasChildren'] as bool,
    );

Map<String, dynamic> _$ContentItemToJson(ContentItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uri': instance.uri,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'imageUri': instance.imageUri,
      'playable': instance.isPlayable,
      'hasChildren': instance.hasChildren,
    };
