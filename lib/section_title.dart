import 'package:flutter/material.dart';
import 'package:spotify_client/spotify_client.dart';
import 'package:spotix/app_text_styles.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    Key? key,
    required this.item,
  }) : super(key: key);

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        item.title,
        style: AppTextStyles.titleLarge,
      ),
    );
  }
}
