import 'dart:async';
import 'dart:developer';

import 'package:rxdart/rxdart.dart';
import 'package:spotify_client/spotify_client.dart';
import 'package:spotix/listeners/state_listener.dart';

class AuthStateListener implements StateListener<SpotifyAuthorizationState> {
  AuthStateListener(this._spotifyClient) {
    _init();
  }

  final SpotifyClient _spotifyClient;

  late final StreamSubscription<SpotifyAuthorizationState> _subscription;

  final BehaviorSubject<SpotifyAuthorizationState> _state =
      BehaviorSubject<SpotifyAuthorizationState>.seeded(
    SpotifyAuthorizationState.defaultValue,
  );

  @override
  SpotifyAuthorizationState get currentValue => _state.value;

  @override
  Stream<SpotifyAuthorizationState> get onChanged => _state.stream;

  void _init() {
    _subscription = _spotifyClient.onAuthStateChanged.listen(
      _state.add,
      onError: onError,
    );
  }

  @override
  void onError(Object error, StackTrace? stackTrace) {
    log(
      'An error occurred while listening to '
      'SpotifyClient.onAuthStateChanged',
      name: 'AuthStateListener._init',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
  }
}
