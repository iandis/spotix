import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify_client/spotify_client.dart';
import 'package:spotix/app_text_styles.dart';
import 'package:spotix/app_theme_controller.dart';
import 'package:spotix/app_themes.dart';
import 'package:spotix/scrollable_text.dart';
import 'package:spotix/content_provider.dart';
import 'package:spotix/offline_storage.dart';
import 'package:spotix/track_extension.dart';
import 'package:spotix/content_image.dart';

const SpotifyClient _spotifyClient = SpotifyClient();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

  final OfflineStorage offlineStorage = OfflineStorage(sharedPreferences);

  runApp(
    ChangeNotifierProvider<AppThemeController>(
      create: (_) => AppThemeController(offlineStorage),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeController>(
      builder: (_, __, ___) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          restorationScopeId: 'spotix-1.0.1',
          title: 'Spotix',
          themeMode: context.read<AppThemeController>().themeMode,
          theme: AppThemes.light,
          darkTheme: AppThemes.dark,
          home: ChangeNotifierProvider<ContentProvider>(
            create: (_) => ContentProvider(),
            child: const HomePage(),
          ),
        );
      },
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
      body: ValueListenableBuilder<bool>(
        valueListenable: _spotifyConnectedState,
        builder: (_, bool isConnected, Widget? child) {
          if (!isConnected) {
            return const SizedBox.shrink();
          }
          return child!;
        },
        child: Selector<ContentProvider, List<ContentItem>>(
          selector: (_, ContentProvider contentProvider) {
            return contentProvider.sections.items;
          },
          builder: (_, List<ContentItem> sections, __) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverAppBar(
                  title: const Text('Spotix'),
                  actions: <Widget>[
                    IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        switchInCurve: Curves.fastLinearToSlowEaseIn,
                        transitionBuilder: (
                          Widget child,
                          Animation<double> animation,
                        ) {
                          return RotationTransition(
                            turns: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: context.read<AppThemeController>().isDarkMode
                            ? const Icon(
                                Icons.dark_mode_rounded,
                                key: ValueKey<bool>(true),
                              )
                            : const Icon(
                                Icons.light_mode_rounded,
                                key: ValueKey<bool>(false),
                              ),
                      ),
                      onPressed:
                          context.read<AppThemeController>().toggleDarkMode,
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_rounded),
                      onPressed: _onInfoPressed,
                    ),
                  ],
                ),
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
                        return ContentSection(index: index, item: item);
                      },
                      childCount: sections.length,
                    ),
                  )
                else
                  const SliverFillRemaining(
                    child: Center(
                      child: CupertinoActivityIndicator(radius: 20),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 70),
                ),
              ],
            );
          },
        ),
      ),
      bottomSheet: ValueListenableBuilder<TrackState?>(
        valueListenable: _spotifyTrackState,
        builder: (_, TrackState? currentState, __) {
          return Container(
            height: 70,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            color: Theme.of(context).backgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  flex: 4,
                  child: Container(
                    height: 45,
                    margin: const EdgeInsets.only(right: 8),
                    child: Row(
                      children: <Widget>[
                        if (currentState != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ContentImage(
                              height: 35,
                              width: 35,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(3)),
                              image: currentState.track,
                            ),
                          ),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Flexible(
                                child: ScrollableText(
                                  currentState?.track.name ?? '-',
                                  maxLines: 1,
                                  style: AppTextStyles.labelLarge,
                                ),
                              ),
                              if (currentState?.track.artistText.isNotEmpty ==
                                  true)
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: ScrollableText(
                                      currentState!.track.artistText,
                                      maxLines: 1,
                                      style: AppTextStyles.labelNormal,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 45,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: currentState != null
                              ? _spotifyClient.skipPrevious
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.skip_previous_rounded,
                              color: currentState != null ? null : Colors.grey,
                              size: 40,
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: currentState != null ? _playOrPause : null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              color: currentState != null ? null : Colors.grey,
                              size: 40,
                              progress: _playButtonAnimationController,
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: currentState != null
                              ? _spotifyClient.skipNext
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.skip_next_rounded,
                              color: currentState != null ? null : Colors.grey,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
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
          name: '_HomePageState._initSpotifyListeners',
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
          name: '_HomePageState._initSpotifyListeners',
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
          name: '_HomePageState._initSpotifyListeners',
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
          applicationVersion: '1.0.1',
          applicationLegalese: 'Copyright 2022 Iandi Santulus. '
              'Protected under the BSD 3-Clause "New" or "Revised" License.',
        );
      },
    );
  }
}

class ContentSection extends StatefulWidget {
  const ContentSection({
    Key? key,
    this.sectionHeight = 300,
    this.itemsHeight = 250,
    required this.index,
    required this.item,
  }) : super(key: key);

  final double sectionHeight;
  final double itemsHeight;

  final int index;
  final ContentItem item;

  @override
  State<ContentSection> createState() => _ContentSectionState();
}

class _ContentSectionState extends State<ContentSection> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.sectionHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionTitle(item: widget.item),
          const SizedBox(height: 10),
          SizedBox(
            height: widget.itemsHeight,
            child: Selector<ContentProvider, List<ContentItem>>(
              selector: (_, ContentProvider contentProvider) {
                return contentProvider.sectionItemList[widget.index].items;
              },
              builder: (_, List<ContentItem> sectionItems, __) {
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

  late final ContentProvider _contentProvider;

  @override
  void initState() {
    super.initState();
    _contentProvider = context.read<ContentProvider>();
    _initItems();
  }

  @override
  void didUpdateWidget(ContentSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initItems();
  }

  void _initItems() {
    if (_contentProvider.sectionItemListState[widget.index] !=
            ContentState.init ||
        !widget.item.hasChildren) {
      return;
    }

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      _contentProvider.refreshSectionItemsOf(widget.index, widget.item);
    });
  }

  void _onChildTapped(ContentItem item) {
    if (item.isPlayable) {
      _spotifyClient.playContent(item);
    }
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    Key? key,
    required this.item,
  }) : super(key: key);

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        item.title,
        style: AppTextStyles.titleLarge,
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
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      child: Container(
        width: itemWidth,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ContentImage(
              image: item,
              height: itemWidth,
              width: itemWidth,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleRegular,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  item.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subtitle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
