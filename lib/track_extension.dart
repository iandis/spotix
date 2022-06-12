import 'package:spotify_client/spotify_client.dart';

extension ArtistTextExtension on Track {
  String get artistText {
    if (artists.length > 1) {
      return artists.map<String>((Artist artist) => artist.name).join(', ');
    } else if (artist.name.isNotEmpty) {
      return artist.name;
    }
    return '';
  }
}
