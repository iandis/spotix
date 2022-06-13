import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:spotify_client/spotify_client.dart';
import 'package:spotix/app_text_styles.dart';
import 'package:spotix/content_image.dart';
import 'package:spotix/di.dart';
import 'package:spotix/scrollable_text.dart';
import 'package:spotix/track_extension.dart';

class TrackPlayerContainer extends StatefulWidget {
  const TrackPlayerContainer({Key? key}) : super(key: key);

  @override
  State<TrackPlayerContainer> createState() => _TrackPlayerContainerState();
}

class _TrackPlayerContainerState extends State<TrackPlayerContainer>
    with SingleTickerProviderStateMixin<TrackPlayerContainer> {
  final ValueNotifier<TrackState?> _spotifyTrackState =
      ValueNotifier<TrackState?>(null);

  late final AnimationController _playButtonAnimationController;

  StreamSubscription<TrackState?>? _trackListener;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TrackState?>(
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
                            ? getIt<SpotifyClient>().skipPrevious
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
                            ? getIt<SpotifyClient>().skipNext
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
    );
  }

  @override
  void initState() {
    super.initState();
    _playButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _initTrackListener();
  }

  @override
  void dispose() {
    _spotifyTrackState.dispose();
    _playButtonAnimationController.dispose();
    _trackListener?.cancel();
    super.dispose();
  }

  void _initTrackListener() {
    _trackListener = getIt<SpotifyClient>().onTrackChanged.listen(
      _onTrackChanged,
      onError: (Object error, StackTrace stackTrace) {
        log(
          'An error occurred while listening to SpotifyClient.onTrackChanged',
          name: '_TrackPlayerContainerState._initTrackListener',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  void _onTrackChanged(TrackState? track) {
    if (track == null) return;
    _spotifyTrackState.value = track;

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
      getIt<SpotifyClient>().resume();
    } else {
      getIt<SpotifyClient>().pause();
    }
  }
}
