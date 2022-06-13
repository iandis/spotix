import 'dart:typed_data';

import 'package:spotify_client/src/entities/content_item.dart';
import 'package:spotify_client/src/entities/content_items.dart';
import 'package:spotify_client/src/states/spotify_authorization_state.dart';
import 'package:spotify_client/src/states/spotify_connection_state.dart';
import 'package:spotify_client/src/spotify_image_dimension.dart';
import 'package:spotify_client/src/states/spotify_player_state.dart';

import 'spotify_client_impl.dart';

abstract class SpotifyClient {
  const factory SpotifyClient() = SpotifyClientImpl;

  Future<bool> get isSpotifyInstalled;

  Stream<SpotifyAuthorizationState> get onAuthStateChanged;

  Stream<SpotifyConnectionState> get onConnectionStateChanged;

  Stream<SpotifyPlayerState> get onPlayerStateChanged;

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
