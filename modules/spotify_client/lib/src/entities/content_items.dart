import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:spotify_client/src/entities/content_item.dart';

part 'content_items.g.dart';

@JsonSerializable()
class ContentItems extends Equatable {
  const ContentItems({
    required this.limit,
    required this.offset,
    required this.total,
    required this.items,
  });

  static const ContentItems defaultValue = ContentItems(
    limit: 0,
    offset: 0,
    total: 0,
    items: <ContentItem>[],
  );

  factory ContentItems.fromJson(Map<String, dynamic> json) =>
      _$ContentItemsFromJson(json);

  final int limit;

  final int offset;

  final int total;

  @JsonKey(fromJson: _itemListFromJson)
  final List<ContentItem> items;

  Map<String, dynamic> get toJson => _$ContentItemsToJson(this);

  @override
  List<Object?> get props => <Object?>[items];
}

List<ContentItem> _itemListFromJson(dynamic data) {
  final List<dynamic> itemList = data as List<dynamic>;
  return itemList.map<ContentItem>((dynamic e) {
    final Map<dynamic, dynamic> map = e as Map<dynamic, dynamic>;
    return ContentItem.fromJson(Map<String, dynamic>.from(map));
  }).toList(growable: false);
}
