import 'package:flutter/material.dart';

class ContentImagePlaceholder extends StatelessWidget {
  const ContentImagePlaceholder({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: const Icon(
        Icons.queue_music_rounded,
      ),
    );
  }
}
