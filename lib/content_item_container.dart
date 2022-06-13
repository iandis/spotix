import 'package:flutter/material.dart';
import 'package:spotify_client/spotify_client.dart';
import 'package:spotix/app_text_styles.dart';
import 'package:spotix/content_image.dart';

class ContentItemContainer extends StatelessWidget {
  const ContentItemContainer({
    Key? key,
    required this.item,
    this.itemWidth = 150,
    required this.onTapped,
  }) : super(key: key);

  final ContentItem item;

  final double itemWidth;

  final ValueChanged<ContentItem> onTapped;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTapped(item),
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      child: Container(
        width: itemWidth,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ContentImage(
              image: item,
              height: itemWidth,
              width: itemWidth,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleRegular,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  item.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subtitle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
