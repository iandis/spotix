import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_client/spotify_client.dart';
import 'package:spotix/content_provider.dart';
import 'package:spotix/di.dart';
import 'package:spotix/listeners/connection_state_listener.dart';

class HomeAppBarTitle extends StatefulWidget {
  const HomeAppBarTitle({Key? key}) : super(key: key);

  @override
  State<HomeAppBarTitle> createState() => _HomeAppBarTitleState();
}

class _HomeAppBarTitleState extends State<HomeAppBarTitle> {
  late final ConnectionStateListener _connectionStateListener;

  StreamSubscription<SpotifyConnectionState>? _connectionListenerSubscriber;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SpotifyConnectionState>(
      initialData: SpotifyConnectionState.disconnected,
      stream: _connectionStateListener.onChanged,
      builder: (_, AsyncSnapshot<SpotifyConnectionState> snapshot) {
        final SpotifyConnectionState state = snapshot.data!;
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
    _connectionStateListener = getIt<ConnectionStateListener>();
    _initConnectionListener();
  }

  @override
  void dispose() {
    _connectionListenerSubscriber?.cancel();
    super.dispose();
  }

  void _connectSpotify() {
    getIt<SpotifyClient>().connect();
  }

  void _initConnectionListener() {
    _connectionListenerSubscriber =
        _connectionStateListener.onChanged.listen(_onConnectionStateChanged);
  }

  void _onConnectionStateChanged(SpotifyConnectionState state) {
    if (state == SpotifyConnectionState.connected) {
      _onRefreshSections();
    }
  }

  Future<void> _onRefreshSections() {
    return context.read<ContentProvider>().refreshSections();
  }
}
