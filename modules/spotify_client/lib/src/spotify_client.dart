import 'dart:typed_data';

import 'package:spotify_client/src/entities/content_item.dart';
import 'package:spotify_client/src/entities/content_items.dart';
import 'package:spotify_client/src/entities/track_state.dart';
import 'package:spotify_client/src/spotify_connection_state.dart';
import 'package:spotify_client/src/spotify_image_dimension.dart';

import 'spotify_client_impl.dart';

abstract class SpotifyClient {
  const factory SpotifyClient() = SpotifyClientImpl;

  Future<bool> get isSpotifyInstalled;

  Future<String?> get currentAuthToken;

  Future<SpotifyConnectionState> get currentConnectionState;

  Future<TrackState?> get currentTrack;

  Stream<String?> get onAuthTokenChanged;

  Stream<SpotifyConnectionState> get onConnectionStateChanged;

  Stream<TrackState?> get onTrackChanged;

  void requestAuthorization();

  void connect();

  void disconnect();

  void playPlaylist(String playlistId);

  void playTrack(String trackId);

  void pause();

  void resume();

  void skipNext();

  void skipPrevious();

  Future<Uint8List?> getImage({
    required String? imageUri,
    SpotifyImageDimension imageDimension = SpotifyImageDimension.thumbnail,
  });

  Future<ContentItems> getContentRecommendations();

  Future<ContentItems> getContentChildren({
    required ContentItem item,
    required int limit,
    required int offset,
  });

  Future<bool> playContent(ContentItem item);
}
