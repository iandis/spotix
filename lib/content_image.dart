import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_client/spotify_client.dart';
import 'package:spotix/content_image_placeholder.dart';
import 'package:spotix/content_provider.dart';

class ContentImage extends StatelessWidget {
  const ContentImage({
    Key? key,
    required this.image,
    required this.height,
    required this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(5)),
  }) : super(key: key);

  final PlaybackImage image;

  final double height;

  final double width;

  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final Widget result;
    if (image.hasImageUrl) {
      result = CachedNetworkImage(
        imageUrl: image.imageUri,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) {
          return ContentImagePlaceholder(
            width: width,
            height: height,
          );
        },
      );
    } else {
      final ContentProvider contentProvider = context.read<ContentProvider>();
      result = FutureBuilder<Uint8List?>(
        future: contentProvider.getImageBytes(image.imageUri),
        builder: (_, AsyncSnapshot<Uint8List?> imageBytesFn) {
          if (imageBytesFn.data == null) {
            return ContentImagePlaceholder(
              width: width,
              height: height,
            );
          }
          return Image.memory(
            imageBytesFn.data!,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return ContentImagePlaceholder(
                width: width,
                height: height,
              );
            },
          );
        },
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
      ),
      clipBehavior: Clip.hardEdge,
      child: result,
    );
  }
}
