abstract class PlaybackImage {
  const PlaybackImage();

  String get imageUri;

  bool get hasImageUrl => imageUri.startsWith('https');
}
