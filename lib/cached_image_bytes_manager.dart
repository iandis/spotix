import 'dart:typed_data';

import 'package:quiver/collection.dart';

class CachedImageBytesManager {
  final Map<String, Future<Uint8List?>> _cachedImageBytes =
      LruMap<String, Future<Uint8List?>>();

  Future<Uint8List?>? get(String key) {
    return _cachedImageBytes[key];
  }

  Future<Uint8List?> put(
    String key,
    Future<Uint8List?> imageBytesFuture,
  ) {
    return _cachedImageBytes[key] ??= imageBytesFuture;
  }
}
