import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:quiver/collection.dart';
import 'package:spotify_client/spotify_client.dart';

enum ContentState { init, loading, loaded }

const SpotifyClient _spotifyClient = SpotifyClient();

class ContentProvider extends ChangeNotifier {
  ContentState _sectionState = ContentState.init;
  ContentState get sectionState => _sectionState;

  ContentItems _sections = ContentItems.defaultValue;
  ContentItems get sections => _sections;

  List<ContentItems> _sectionItemList = <ContentItems>[];
  List<ContentItems> get sectionItemList => _sectionItemList;

  List<ContentState> _sectionItemListState = <ContentState>[];
  List<ContentState> get sectionItemListState => _sectionItemListState;

  Future<void> refreshSections() async {
    final bool isConnected = await _spotifyClient.currentConnectionState ==
        SpotifyConnectionState.connected;
    if (_sectionState == ContentState.loading || !isConnected) return;

    _sectionState = ContentState.loading;
    notifyListeners();

    final ContentItems sections =
        await _spotifyClient.getContentRecommendations();
    _sections = sections;
    _initSectionItems(sections.items);

    _sectionState = ContentState.loaded;
    notifyListeners();
  }

  void _initSectionItems(
    List<ContentItem> sections, {
    void Function(int index, ContentItem item)? onEach,
  }) {
    for (int index = 0; index < sections.length; index++) {
      final ContentItem item = sections[index];
      if (!item.hasChildren) continue;
      if (index > _sectionItemList.length - 1) {
        _sectionItemList.add(ContentItems.defaultValue);
        _sectionItemListState.add(ContentState.init);
      } else {
        _sectionItemListState[index] = ContentState.init;
      }
      onEach?.call(index, item);
    }
    if (_sections.items.length < _sectionItemList.length) {
      _sectionItemList.removeRange(
        _sections.items.length,
        _sectionItemList.length,
      );
    }
  }

  Future<void> refreshSectionItemsOf(int index, ContentItem section) async {
    if (_sectionItemListState[index] == ContentState.loading) return;
    _sectionItemListState[index] = ContentState.loading;
    notifyListeners();

    final ContentItems sectionItems = await _spotifyClient.getContentChildren(
      item: section,
      limit: 10,
      offset: 0,
    );
    // Prevent losing reference to current items
    _sectionItemList[index] = _sectionItemList[index] != sectionItems
        ? sectionItems
        : _sectionItemList[index];
    _sectionItemListState[index] = ContentState.loaded;
    notifyListeners();
  }

  final Map<String, Future<Uint8List?>> _cachedImageBytes =
      LruMap<String, Future<Uint8List?>>(maximumSize: 100);

  Future<Uint8List?> getImageBytes(String imageUri) {
    return _cachedImageBytes[imageUri] ??=
        _spotifyClient.getImage(imageUri: imageUri);
  }

  void clearItems() {
    _sectionState = ContentState.init;
    _sections = ContentItems.defaultValue;
    _sectionItemList = <ContentItems>[];
    _sectionItemListState = <ContentState>[];
    notifyListeners();
  }
}
