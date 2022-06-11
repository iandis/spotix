import 'package:flutter/foundation.dart';
import 'package:spotify_client/spotify_client.dart';

enum ContentState { init, loading, loaded }

const SpotifyClient _spotifyClient = SpotifyClient();

class ContentProvider extends ChangeNotifier {
  ContentState _sectionState = ContentState.init;
  ContentState get sectionState => _sectionState;

  ContentItems _sections = ContentItems.defaultValue;
  ContentItems get sections => _sections;

  Map<ContentItem, ContentItems> _sectionItems = <ContentItem, ContentItems>{};
  ContentItems getSectionItems(ContentItem section) {
    return _sectionItems[section]!;
  }

  Map<ContentItem, ContentState> _sectionItemsState =
      <ContentItem, ContentState>{};
  ContentState getSectionItemsState(ContentItem section) {
    return _sectionItemsState[section]!;
  }

  Future<void> refreshSections() async {
    final bool isConnected = await _spotifyClient.currentConnectionState ==
        SpotifyConnectionState.connected;
    if (_sectionState == ContentState.loading || !isConnected) return;

    _sectionState = ContentState.loading;
    notifyListeners();

    final ContentItems sections =
        await _spotifyClient.getContentRecommendations();
    _sections = sections;

    _sectionState = ContentState.loaded;
    notifyListeners();

    refreshSectionItems();
  }

  Future<void> refreshSectionItems() async {
    final List<Future<void>> processList = <Future<void>>[];
    for (final ContentItem item in _sections.items) {
      if (!item.hasChildren) continue;
      _sectionItems[item] ??= ContentItems.defaultValue;
      _sectionItemsState[item] = ContentState.init;
      processList.add(refreshSectionItemsOf(item));
    }
    await Future.wait<void>(processList);
    notifyListeners();
  }

  Future<void> refreshSectionItemsOf(ContentItem section) async {
    if (getSectionItemsState(section) == ContentState.loading) return;
    _sectionItemsState[section] = ContentState.loading;

    final ContentItems sectionItems = await _spotifyClient.getContentChildren(
      item: section,
      limit: 10,
      offset: 0,
    );
    _sectionItems[section] = sectionItems;

    _sectionItemsState[section] = ContentState.loaded;
  }

  void clearItems() {
    _sectionState = ContentState.init;
    _sections = ContentItems.defaultValue;
    _sectionItems = <ContentItem, ContentItems>{};
    _sectionItemsState = <ContentItem, ContentState>{};
    notifyListeners();
  }
}
