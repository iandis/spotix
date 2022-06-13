import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:spotify_client/spotify_client.dart';
import 'package:spotix/content_item_container.dart';
import 'package:spotix/content_provider.dart';
import 'package:spotix/di.dart';
import 'package:spotix/section_title.dart';

class ContentSection extends StatefulWidget {
  const ContentSection({
    Key? key,
    this.sectionHeight = 300,
    this.itemsHeight = 250,
    required this.index,
    required this.item,
  }) : super(key: key);

  final double sectionHeight;
  final double itemsHeight;

  final int index;
  final ContentItem item;

  @override
  State<ContentSection> createState() => _ContentSectionState();
}

class _ContentSectionState extends State<ContentSection> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.sectionHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionTitle(item: widget.item),
          const SizedBox(height: 10),
          SizedBox(
            height: widget.itemsHeight,
            child: Selector<ContentProvider, List<ContentItem>>(
              selector: (_, ContentProvider contentProvider) {
                return contentProvider.sectionItemList[widget.index].items;
              },
              builder: (_, List<ContentItem> sectionItems, __) {
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: sectionItems.isEmpty ? 1 : sectionItems.length,
                  itemBuilder: (_, int index) {
                    if (sectionItems.isEmpty) {
                      return Container(
                        height: widget.itemsHeight * 0.5,
                        width: widget.itemsHeight * 0.5,
                        alignment: Alignment.center,
                        child: const CupertinoActivityIndicator(radius: 10),
                      );
                    }
                    final ContentItem item = sectionItems[index];
                    return ContentItemContainer(
                      item: item,
                      onTapped: _onChildTapped,
                    );
                  },
                  separatorBuilder: (_, __) {
                    return const SizedBox(width: 12);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  late final ContentProvider _contentProvider;

  @override
  void initState() {
    super.initState();
    _contentProvider = context.read<ContentProvider>();
    _initItems();
  }

  @override
  void didUpdateWidget(ContentSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initItems();
  }

  void _initItems() {
    if (_contentProvider.sectionItemListState[widget.index] !=
            ContentState.init ||
        !widget.item.hasChildren) {
      return;
    }

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      _contentProvider.refreshSectionItemsOf(widget.index, widget.item);
    });
  }

  void _onChildTapped(ContentItem item) {
    if (item.isPlayable) {
      getIt<SpotifyClient>().playContent(item);
    }
  }
}
