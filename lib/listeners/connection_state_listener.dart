import 'dart:async';
import 'dart:developer';

import 'package:rxdart/rxdart.dart';
import 'package:spotify_client/spotify_client.dart';
import 'package:spotix/listeners/state_listener.dart';

class ConnectionStateListener implements StateListener<SpotifyConnectionState> {
  ConnectionStateListener(this._spotifyClient) {
    _init();
  }

  final SpotifyClient _spotifyClient;

  late final StreamSubscription<SpotifyConnectionState> _subscription;

  final BehaviorSubject<SpotifyConnectionState> _state =
      BehaviorSubject<SpotifyConnectionState>.seeded(
    SpotifyConnectionState.disconnected,
  );

  @override
  SpotifyConnectionState get currentValue => _state.value;

  @override
  Stream<SpotifyConnectionState> get onChanged => _state.stream;

  void _init() {
    _subscription = _spotifyClient.onConnectionStateChanged.listen(
      _state.add,
      onError: onError,
    );
  }

  @override
  void onError(Object error, StackTrace? stackTrace) {
    log(
      'An error occurred while listening to '
      'SpotifyClient.onConnectionStateChanged',
      name: 'ConnectionStateListener._init',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
  }
}
