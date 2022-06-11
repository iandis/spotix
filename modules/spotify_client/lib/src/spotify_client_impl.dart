import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:spotify_client/src/entities/content_items.dart';
import 'package:spotify_client/src/entities/content_item.dart';
import 'package:spotify_client/src/entities/track_state.dart';
import 'package:spotify_client/src/spotify_connection_state.dart';
import 'package:spotify_client/src/spotify_client.dart';
import 'package:spotify_client/src/spotify_image_dimension.dart';

class SpotifyClientImpl implements SpotifyClient {
  const SpotifyClientImpl();

  static const String _methodChannelName = 'spotify_client_method_channel';
  static const MethodChannel _methodChannel = MethodChannel(_methodChannelName);

  static const String _eventChannelName = 'spotify_client_event_channel';
  static const String _authStateEventChannelName =
      '$_eventChannelName#onAuthTokenChanged';
  static const EventChannel _authStateEventChannel =
      EventChannel(_authStateEventChannelName);

  static const String _connectionStateEventChannelName =
      '$_eventChannelName#onConnectionStateChanged';
  static const EventChannel _connectionStateEventChannel =
      EventChannel(_connectionStateEventChannelName);

  static const String _trackStateEventChannelName =
      '$_eventChannelName#onTrackChanged';
  static const EventChannel _trackStateEventChannel =
      EventChannel(_trackStateEventChannelName);

  @override
  Future<bool> get isSpotifyInstalled async {
    bool isSpotifyInstalled = false;
    try {
      final bool? result =
          await _methodChannel.invokeMethod<bool>('isSpotifyInstalled');

      isSpotifyInstalled = result ?? false;
    } catch (error, stackTrace) {
      log(
        'An error occurred while checking spotify app existence.',
        name: 'SpotifyClientImpl.isSpotifyInstalled',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return isSpotifyInstalled;
  }

  @override
  Future<String?> get currentAuthToken async {
    try {
      return await _methodChannel.invokeMethod<String>('currentAuthToken');
    } catch (error, stackTrace) {
      log(
        'An error occurred while getting current auth token.',
        name: 'SpotifyClientImpl.currentAuthToken',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return null;
  }

  SpotifyConnectionState _convertOrdinalToConnectionState(int? ordinal) {
    return SpotifyConnectionState.values.firstWhere(
      (SpotifyConnectionState state) => state.index == ordinal,
      orElse: () => SpotifyConnectionState.disconnected,
    );
  }

  @override
  Future<SpotifyConnectionState> get currentConnectionState async {
    SpotifyConnectionState currentState = SpotifyConnectionState.disconnected;
    try {
      final int? result =
          await _methodChannel.invokeMethod<int>('currentConnectionState');
      currentState = _convertOrdinalToConnectionState(result);
    } catch (error, stackTrace) {
      log(
        'An error occurred while checking spotify app remote connection.',
        name: 'SpotifyClientImpl.currentConnectionState',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return currentState;
  }

  @override
  Future<TrackState?> get currentTrack async {
    try {
      final Map<Object?, Object?>? result = await _methodChannel
          .invokeMapMethod<Object?, Object?>('currentTrack');
      if (result != null) {
        return TrackState.fromJson(Map<String, dynamic>.from(result));
      }
    } catch (error, stackTrace) {
      log(
        'An error occurred while getting current playing track.',
        name: 'SpotifyClientImpl.currentTrack',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return null;
  }

  @override
  Stream<String?> get onAuthTokenChanged {
    return _authStateEventChannel
        .receiveBroadcastStream('onAuthTokenChanged')
        .map<String?>((dynamic data) => data as String?);
  }

  @override
  Stream<SpotifyConnectionState> get onConnectionStateChanged {
    return _connectionStateEventChannel
        .receiveBroadcastStream('onConnectionStateChanged')
        .map<SpotifyConnectionState>(
          (dynamic data) => _convertOrdinalToConnectionState(data as int),
        );
  }

  @override
  Stream<TrackState?> get onTrackChanged {
    return _trackStateEventChannel
        .receiveBroadcastStream('onTrackChanged')
        .map<TrackState?>(
          (dynamic data) => data is Map<dynamic, dynamic>
              ? TrackState.fromJson(Map<String, dynamic>.from(data))
              : null,
        );
  }

  @override
  void requestAuthorization() {
    _methodChannel.invokeMethod<bool>('requestAuthorization');
  }

  @override
  void connect() {
    _methodChannel.invokeMethod<bool>('connect');
  }

  @override
  void disconnect() {
    _methodChannel.invokeMethod<bool>('disconnect');
  }

  @override
  void playPlaylist(String playlistId) {
    _methodChannel.invokeMethod<bool>('playPlaylist', playlistId);
  }

  @override
  void playTrack(String trackId) {
    _methodChannel.invokeMethod<bool>('playTrack', trackId);
  }

  @override
  void pause() {
    _methodChannel.invokeMethod<bool>('pause');
  }

  @override
  void resume() {
    _methodChannel.invokeMethod<bool>('resume');
  }

  @override
  void skipNext() {
    _methodChannel.invokeMethod<bool>('skipNext');
  }

  @override
  void skipPrevious() {
    _methodChannel.invokeMethod<bool>('skipPrevious');
  }

  @override
  Future<Uint8List?> getImage({
    required String? imageUri,
    SpotifyImageDimension imageDimension = SpotifyImageDimension.thumbnail,
  }) async {
    try {
      final Map<String, dynamic> arguments = <String, dynamic>{
        'imageUri': imageUri,
        'imageDimension': imageDimension.value,
      };
      final Uint8List? result =
          await _methodChannel.invokeMethod<Uint8List>('getImage', arguments);
      return result;
    } catch (error, stackTrace) {
      log(
        'An error occurred while getting image from image uri.',
        name: 'SpotifyClientImpl.getImage',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return null;
  }

  @override
  Future<ContentItems> getContentRecommendations() async {
    try {
      final Map<Object?, Object?>? result = await _methodChannel
          .invokeMapMethod<Object?, Object?>('getContentRecommendations');
      if (result != null) {
        return ContentItems.fromJson(Map<String, dynamic>.from(result));
      }
    } catch (error, stackTrace) {
      log(
        'An error occurred while getting content recommendations.',
        name: 'SpotifyClientImpl.getContentRecommendations',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return ContentItems.defaultValue;
  }

  @override
  Future<ContentItems> getContentChildren({
    required ContentItem item,
    required int limit,
    required int offset,
  }) async {
    try {
      final Map<String, dynamic> arguments = <String, dynamic>{
        'limit': limit,
        'offset': offset,
        'item': item.toJson,
      };
      final Map<Object?, Object?>? result = await _methodChannel
          .invokeMapMethod<Object?, Object?>('getContentChildren', arguments);
      if (result != null) {
        return ContentItems.fromJson(Map<String, dynamic>.from(result));
      }
    } catch (error, stackTrace) {
      log(
        'An error occurred while getting content children.',
        name: 'SpotifyClientImpl.getContentChildren',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return ContentItems.defaultValue;
  }

  @override
  Future<bool> playContent(ContentItem item) async {
    try {
      final bool? result =
          await _methodChannel.invokeMethod<bool>('playContent', item.toJson);
      return result ?? false;
    } catch (error, stackTrace) {
      log(
        'An error occurred while trying to play content.',
        name: 'SpotifyClientImpl.playContent',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return false;
  }
}
