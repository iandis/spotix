import 'dart:typed_data';

import 'package:spotify_client/spotify_client.dart';

final Map<ContentItem, Future<Uint8List?>> _cachedImageBytes =
    <ContentItem, Future<Uint8List?>>{};

extension ContentImageExtension on ContentItem {
  Future<Uint8List?> getImageBytes(SpotifyClient spotifyClient) {
    return _cachedImageBytes[this] ??= spotifyClient.getImage(
      imageUri: imageUri,
      imageDimension: SpotifyImageDimension.medium,
    );
  }
}
