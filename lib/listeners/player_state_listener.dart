import 'dart:async';
import 'dart:developer';

import 'package:rxdart/rxdart.dart';
import 'package:spotify_client/spotify_client.dart';
import 'package:spotix/listeners/state_listener.dart';

class PlayerStateListener implements StateListener<SpotifyPlayerState> {
  PlayerStateListener(this._spotifyClient) {
    _init();
  }

  final SpotifyClient _spotifyClient;

  late final StreamSubscription<SpotifyPlayerState> _subscription;

  final BehaviorSubject<SpotifyPlayerState> _state =
      BehaviorSubject<SpotifyPlayerState>.seeded(
    SpotifyPlayerState.defaultValue,
  );

  @override
  SpotifyPlayerState get currentValue => _state.value;

  @override
  Stream<SpotifyPlayerState> get onChanged => _state.stream;

  void _init() {
    _subscription = _spotifyClient.onPlayerStateChanged.listen(
      _state.add,
      onError: onError,
    );
  }

  @override
  void onError(Object error, StackTrace? stackTrace) {
    log(
      'An error occurred while listening to '
      'SpotifyClient.onPlayerStateChanged',
      name: 'PlayerStateListener._init',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
  }
}
