import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_client/spotify_client.dart';
import 'package:spotix/content_provider.dart';
import 'package:spotix/di.dart';

class HomeAppBarTitle extends StatefulWidget {
  const HomeAppBarTitle({Key? key}) : super(key: key);

  @override
  State<HomeAppBarTitle> createState() => _HomeAppBarTitleState();
}

class _HomeAppBarTitleState extends State<HomeAppBarTitle> {
  final ValueNotifier<SpotifyConnectionState> _connectionState =
      ValueNotifier<SpotifyConnectionState>(
    SpotifyConnectionState.disconnected,
  );

  StreamSubscription<SpotifyConnectionState>? _connectionListener;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SpotifyConnectionState>(
      valueListenable: _connectionState,
      builder: (_, SpotifyConnectionState state, __) {
        if (state == SpotifyConnectionState.connected) {
          return const Text('Spotix');
        }

        return Row(
          children: <Widget>[
            const Text('Spotix'),
            if (state == SpotifyConnectionState.disconnected)
              IconButton(
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                onPressed: _connectSpotify,
              )
            else
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: CupertinoActivityIndicator(),
              ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initConnectionListener();
  }

  @override
  void dispose() {
    _connectionState.dispose();
    _connectionListener?.cancel();
    super.dispose();
  }

  void _connectSpotify() {
    getIt<SpotifyClient>().connect();
  }

  void _initConnectionListener() {
    _connectionListener =
        getIt<SpotifyClient>().onConnectionStateChanged.listen(
      _onConnectionStateChanged,
      onError: (Object error, StackTrace stackTrace) {
        log(
          'An error occurred while listening to SpotifyClient.onConnectionStateChanged',
          name: '_HomeAppBarTitleState._initConnectionListener',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  void _onConnectionStateChanged(SpotifyConnectionState state) {
    _connectionState.value = state;
    if (state == SpotifyConnectionState.connected) {
      _onRefreshSections();
    }
  }

  Future<void> _onRefreshSections() {
    return context.read<ContentProvider>().refreshSections();
  }
}
