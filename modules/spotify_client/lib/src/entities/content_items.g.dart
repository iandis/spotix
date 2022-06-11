// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_items.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentItems _$ContentItemsFromJson(Map<String, dynamic> json) => ContentItems(
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      total: json['total'] as int,
      items: _itemListFromJson(json['items']),
    );

Map<String, dynamic> _$ContentItemsToJson(ContentItems instance) =>
    <String, dynamic>{
      'limit': instance.limit,
      'offset': instance.offset,
      'total': instance.total,
      'items': instance.items,
    };
