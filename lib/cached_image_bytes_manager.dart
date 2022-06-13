import 'dart:typed_data';

import 'package:quiver/collection.dart';

class CachedImageBytesManager {
  final Map<String, Future<Uint8List?>> _cachedImageBytes =
      LruMap<String, Future<Uint8List?>>(maximumSize: 100);

  Future<Uint8List?> get(String key) {
    final Future<Uint8List?>? cached = _cachedImageBytes[key];
    assert(
      cached != null,
      'Cached image bytes not found! Make sure to call `CachedImageBytesManager.put` before trying to get the cached image bytes.',
    );
    return cached!;
  }

  void put(
    String key,
    Future<Uint8List?> imageBytesFuture,
  ) {
    _cachedImageBytes[key] ??= imageBytesFuture;
  }
}
