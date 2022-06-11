import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:spotify_client/spotify_client.dart';
import 'package:spotix/content_image_extension.dart';
import 'package:spotix/content_provider.dart';

const SpotifyClient _spotifyClient = SpotifyClient();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spotix',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: ChangeNotifierProvider<ContentProvider>(
        create: (_) => ContentProvider(),
        child: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin<HomePage> {
  late final ContentProvider _contentProvider;

  final ValueNotifier<bool> _spotifyConnectedState = ValueNotifier<bool>(false);

  final ValueNotifier<TrackState?> _spotifyTrackState =
      ValueNotifier<TrackState?>(null);

  late final AnimationController _playButtonAnimationController;

  StreamSubscription<String?>? _authTokenListener;

  StreamSubscription<SpotifyConnectionState>? _connectionListener;

  StreamSubscription<TrackState?>? _trackListener;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        title: const Text('Spotix'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.info_rounded),
            onPressed: _onInfoPressed,
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _spotifyConnectedState,
        builder: (_, bool isConnected, Widget? child) {
          if (!isConnected) {
            return const SizedBox.shrink();
          }
          return child!;
        },
        child: Consumer<ContentProvider>(
          builder: (_, ContentProvider contentProvider, __) {
            final List<ContentItem> sections = contentProvider.sections.items;
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: <Widget>[
                if (sections.isNotEmpty)
                  CupertinoSliverRefreshControl(
                    onRefresh: _onRefreshRecommendedContents,
                  )
                else
                  const SliverToBoxAdapter(),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
                if (sections.isNotEmpty)
                  SliverFixedExtentList(
                    itemExtent: 300,
                    delegate: SliverChildBuilderDelegate(
                      (_, int index) {
                        final ContentItem item = sections[index];
                        return ContentSection(item: item);
                      },
                      childCount: sections.length,
                    ),
                  )
                else
                  const SliverFillRemaining(
                    child: Center(
                      child: Text('Loading...'),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 150),
                ),
              ],
            );
          },
        ),
      ),
      bottomSheet: ValueListenableBuilder<TrackState?>(
        valueListenable: _spotifyTrackState,
        builder: (_, TrackState? currentState, __) {
          if (currentState == null) {
            return const SizedBox.shrink();
          }
          final String currentTrackText = currentState
                  .track.artist.name.isNotEmpty
              ? '${currentState.track.artist.name} - ${currentState.track.name}'
              : currentState.track.name;

          return Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              boxShadow: <BoxShadow>[
                BoxShadow(
                  blurRadius: 0.5,
                  color: Colors.grey[200]!,
                  offset: const Offset(0.0, -6.0),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    currentTrackText,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _spotifyClient.skipPrevious,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.skip_previous_rounded,
                            size: 60,
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _playOrPause,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AnimatedIcon(
                            icon: AnimatedIcons.play_pause,
                            size: 60,
                            progress: _playButtonAnimationController,
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _spotifyClient.skipNext,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.skip_next_rounded,
                            size: 60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _playButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _contentProvider = context.read<ContentProvider>();
    _checkSpotifyApp();
  }

  @override
  void dispose() {
    _spotifyConnectedState.dispose();
    _spotifyTrackState.dispose();
    _playButtonAnimationController.dispose();
    _authTokenListener?.cancel();
    _connectionListener?.cancel();
    _trackListener?.cancel();
    _spotifyClient.disconnect();
    super.dispose();
  }

  Future<void> _checkSpotifyApp() async {
    final bool isSpotifyInstalled = await _spotifyClient.isSpotifyInstalled;
    if (!isSpotifyInstalled) {
      return SchedulerBinding.instance?.addPostFrameCallback((_) {
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
      });
    }
    _initSpotifyListeners();
    _requestAuthorization();
  }

  void _initSpotifyListeners() {
    _authTokenListener = _spotifyClient.onAuthTokenChanged.listen(
      _onAuthTokenChanged,
      onError: (Object error, StackTrace stackTrace) {
        log(
          'An error occurred while listening to SpotifyClient.onAuthStateChanged',
          name: '_HomePageState._checkSpotifyApp',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
    _connectionListener = _spotifyClient.onConnectionStateChanged.listen(
      _onConnectionStateChanged,
      onError: (Object error, StackTrace stackTrace) {
        log(
          'An error occurred while listening to SpotifyClient.onConnectionStateChanged',
          name: '_HomePageState._checkSpotifyApp',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
    _trackListener = _spotifyClient.onTrackChanged.listen(
      _onTrackChanged,
      onError: (Object error, StackTrace stackTrace) {
        log(
          'An error occurred while listening to SpotifyClient.onTrackChanged',
          name: '_HomePageState._checkSpotifyApp',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  void _requestAuthorization() {
    _spotifyClient.requestAuthorization();
  }

  void _onAuthTokenChanged(String? authToken) {
    if (authToken != null) {
      _spotifyClient.connect();
    } else {
      _spotifyClient.disconnect();
    }
  }

  void _onConnectionStateChanged(SpotifyConnectionState state) {
    _spotifyConnectedState.value = state == SpotifyConnectionState.connected;
    if (state == SpotifyConnectionState.connected) {
      _onRefreshRecommendedContents();
    } else {
      _onClearRecommendedContents();
    }
  }

  void _onTrackChanged(TrackState? track) {
    _spotifyTrackState.value = track;
    if (track == null) return;

    _playButtonAnimationController.stop();

    if (track.isPaused && _playButtonAnimationController.value > 0) {
      _playButtonAnimationController.reverse();
    } else if (!track.isPaused && _playButtonAnimationController.value < 1) {
      _playButtonAnimationController.forward();
    }
  }

  void _playOrPause() {
    final TrackState? currentState = _spotifyTrackState.value;
    if (currentState == null) return;

    if (currentState.isPaused) {
      _spotifyClient.resume();
    } else {
      _spotifyClient.pause();
    }
  }

  void _onClearRecommendedContents() {
    _contentProvider.clearItems();
  }

  Future<void> _onRefreshRecommendedContents() {
    return _contentProvider.refreshSections();
  }

  void _onInfoPressed() {
    showDialog<void>(
      context: context,
      builder: (_) {
        return const AboutDialog(
          applicationName: 'Spotix',
          applicationVersion: '1.0.0+1',
          applicationLegalese: 'Copyright 2022 Iandi Santulus. '
              'Protected under the BSD 3-Clause "New" or "Revised" License.',
        );
      },
    );
  }
}

class ContentSection extends StatelessWidget {
  const ContentSection({
    Key? key,
    this.sectionHeight = 300,
    this.itemsHeight = 250,
    required this.item,
  }) : super(key: key);

  final double sectionHeight;
  final double itemsHeight;

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: sectionHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              item.title,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: itemsHeight,
            child: Consumer<ContentProvider>(
              builder: (_, ContentProvider contentProvider, __) {
                final List<ContentItem> sectionItems =
                    contentProvider.getSectionItems(item).items;
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: sectionItems.length,
                  itemBuilder: (_, int index) {
                    final ContentItem item = sectionItems[index];
                    return ContentItemContainer(
                      item: item,
                      onTapped: _onChildTapped,
                    );
                  },
                  separatorBuilder: (_, __) {
                    return const SizedBox(width: 12);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _onChildTapped(ContentItem item) {
    if (item.isPlayable) {
      _spotifyClient.playContent(item);
    }
  }
}

class ContentImagePlaceholder extends StatelessWidget {
  const ContentImagePlaceholder({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: const Icon(
        Icons.queue_music_rounded,
      ),
    );
  }
}

class ContentItemContainer extends StatelessWidget {
  const ContentItemContainer({
    Key? key,
    required this.item,
    this.itemWidth = 150,
    required this.onTapped,
  }) : super(key: key);

  final ContentItem item;

  final double itemWidth;

  final ValueChanged<ContentItem> onTapped;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTapped(item),
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      child: Container(
        width: itemWidth,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (item.hasImageUrl)
              CachedNetworkImage(
                cacheKey: item.id,
                imageUrl: item.imageUri,
                width: itemWidth,
                height: itemWidth,
                errorWidget: (_, __, ___) {
                  return ContentImagePlaceholder(
                    width: itemWidth,
                    height: itemWidth,
                  );
                },
              )
            else
              FutureBuilder<Uint8List?>(
                future: item.getImageBytes(_spotifyClient),
                builder: (_, AsyncSnapshot<Uint8List?> imageBytesFn) {
                  if (imageBytesFn.data == null) {
                    return ContentImagePlaceholder(
                      width: itemWidth,
                      height: itemWidth,
                    );
                  }
                  return Image.memory(
                    imageBytesFn.data!,
                    width: itemWidth,
                    height: itemWidth,
                    errorBuilder: (_, __, ___) {
                      return ContentImagePlaceholder(
                        width: itemWidth,
                        height: itemWidth,
                      );
                    },
                  );
                },
              ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  item.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2
                      ?.copyWith(fontWeight: FontWeight.w300),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
