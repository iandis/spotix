import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:spotify_client/spotify_client.dart';
import 'package:spotix/content_provider.dart';
import 'package:spotix/content_section.dart';
import 'package:spotix/di.dart';
import 'package:spotix/home_sliver_app_bar.dart';
import 'package:spotix/listeners/auth_state_listener.dart';
import 'package:spotix/listeners/connection_state_listener.dart';
import 'package:spotix/track_player_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final AuthStateListener _authStateListener;
  late final ConnectionStateListener _connectionStateListener;

  StreamSubscription<SpotifyAuthorizationState>? _authStateListenerSubscriber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          const HomeSliverAppBar(),
          Selector<ContentProvider, List<ContentItem>>(
            selector: (_, ContentProvider contentProvider) {
              return contentProvider.sections.items;
            },
            builder: (_, List<ContentItem> sections, __) {
              if (sections.isNotEmpty) {
                return CupertinoSliverRefreshControl(
                  onRefresh: context.read<ContentProvider>().refreshSections,
                );
              }
              return const SliverToBoxAdapter();
            },
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
          Selector<ContentProvider, List<ContentItem>>(
            selector: (_, ContentProvider contentProvider) {
              return contentProvider.sections.items;
            },
            builder: (_, List<ContentItem> sections, __) {
              if (sections.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CupertinoActivityIndicator(radius: 20),
                  ),
                );
              }
              return SliverFixedExtentList(
                itemExtent: 300,
                delegate: SliverChildBuilderDelegate(
                  (_, int index) {
                    final ContentItem item = sections[index];
                    return ContentSection(index: index, item: item);
                  },
                  childCount: sections.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 70),
          ),
        ],
      ),
      bottomSheet: const TrackPlayerContainer(),
    );
  }

  @override
  void initState() {
    super.initState();
    _authStateListener = getIt<AuthStateListener>();
    _connectionStateListener = getIt<ConnectionStateListener>();
    _checkSpotifyApp();
  }

  @override
  void dispose() {
    _authStateListenerSubscriber?.cancel();
    getIt<SpotifyClient>().disconnect();
    super.dispose();
  }

  Future<void> _checkSpotifyApp() async {
    final bool isSpotifyInstalled =
        await getIt<SpotifyClient>().isSpotifyInstalled;
    if (!isSpotifyInstalled) {
      return SchedulerBinding.instance?.addPostFrameCallback((_) {
        _showSpotifyNotFoundDialog();
      });
    }
    _initAuthListener();
    _requestAuthorization();
  }

  void _showSpotifyNotFoundDialog() {
    showDialog<void>(
      context: context,
      builder: (_) {
        return WillPopScope(
          onWillPop: () async => false,
          child: const AlertDialog(
            title: Text('Spotify Belum Diinstall!'),
            content: Text(
              'Untuk melanjutkan, silahkan install Spotify terlebih dahulu.',
            ),
          ),
        );
      },
    );
  }

  void _initAuthListener() {
    _authStateListenerSubscriber =
        _authStateListener.onChanged.listen(_onAuthStateChanged);
  }

  void _requestAuthorization() {
    getIt<SpotifyClient>().requestAuthorization();
  }

  void _onAuthStateChanged(SpotifyAuthorizationState authState) {
    final bool isDisconnected = _connectionStateListener.currentValue ==
        SpotifyConnectionState.disconnected;
    if (authState.status == AuthStatus.authorized && isDisconnected) {
      getIt<SpotifyClient>().connect();
    }
  }
}
