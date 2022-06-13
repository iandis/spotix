import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spotify_client/spotify_client.dart';
import 'package:spotix/app_text_styles.dart';
import 'package:spotix/content_image.dart';
import 'package:spotix/di.dart';
import 'package:spotix/listeners/player_state_listener.dart';
import 'package:spotix/scrollable_text.dart';
import 'package:spotix/track_extension.dart';
import 'package:spotix/track_playback_position_container.dart';

class TrackPlayerContainer extends StatefulWidget {
  const TrackPlayerContainer({Key? key}) : super(key: key);

  @override
  State<TrackPlayerContainer> createState() => _TrackPlayerContainerState();
}

class _TrackPlayerContainerState extends State<TrackPlayerContainer>
    with SingleTickerProviderStateMixin<TrackPlayerContainer> {
  late final PlayerStateListener _playerStateListener;
  late final SpotifyClient _spotifyClient;
  late final AnimationController _playButtonAnimationController;

  StreamSubscription<SpotifyPlayerState>? _playerStateListenerSubscriber;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: Theme.of(context).backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const TrackPlaybackPositionContainer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: StreamBuilder<SpotifyPlayerState>(
              initialData: SpotifyPlayerState.defaultValue,
              stream: _playerStateListener.onChanged,
              builder: (_, AsyncSnapshot<SpotifyPlayerState> snapshot) {
                final SpotifyPlayerState currentState = snapshot.data!;
                final bool canSkipPrev =
                    currentState.playbackRestrictions.canSkipPrev;
                final bool canPlayOrPause = currentState.track != null;
                final bool canSkipNext =
                    currentState.playbackRestrictions.canSkipNext;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 4,
                      child: Container(
                        height: 45,
                        margin: const EdgeInsets.only(right: 8),
                        child: Row(
                          children: <Widget>[
                            if (currentState.track != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ContentImage(
                                  height: 35,
                                  width: 35,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(3)),
                                  image: currentState.track!,
                                ),
                              ),
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Flexible(
                                    child: ScrollableText(
                                      currentState.track?.name ?? '-',
                                      maxLines: 1,
                                      style: AppTextStyles.labelLarge,
                                    ),
                                  ),
                                  if (currentState
                                          .track?.artistText.isNotEmpty ==
                                      true)
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: ScrollableText(
                                          currentState.track!.artistText,
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
                              onTap: canSkipPrev ? _skipPrevious : null,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  Icons.skip_previous_rounded,
                                  color: canSkipPrev ? null : Colors.grey,
                                  size: 40,
                                ),
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: canPlayOrPause ? _playOrPause : null,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: AnimatedIcon(
                                  icon: AnimatedIcons.play_pause,
                                  color: canPlayOrPause ? null : Colors.grey,
                                  size: 40,
                                  progress: _playButtonAnimationController,
                                ),
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: canSkipNext ? _skipNext : null,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  Icons.skip_next_rounded,
                                  color: canSkipNext ? null : Colors.grey,
                                  size: 40,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
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
    _playerStateListener = getIt<PlayerStateListener>();
    _spotifyClient = getIt<SpotifyClient>();
    _initTrackListener();
  }

  @override
  void dispose() {
    _playButtonAnimationController.dispose();
    _playerStateListenerSubscriber?.cancel();
    super.dispose();
  }

  void _initTrackListener() {
    _playerStateListenerSubscriber =
        _playerStateListener.onChanged.listen(_onPlayerStateChanged);
  }

  void _onPlayerStateChanged(SpotifyPlayerState state) {
    if (state.track == null) return;

    _playButtonAnimationController.stop();

    if (state.isPaused && _playButtonAnimationController.value > 0) {
      _playButtonAnimationController.reverse();
    } else if (!state.isPaused && _playButtonAnimationController.value < 1) {
      _playButtonAnimationController.forward();
    }
  }

  void _skipPrevious() {
    final SpotifyPlayerState currentState = _playerStateListener.currentValue;
    if (currentState.track != null &&
        currentState.playbackRestrictions.canSkipPrev) {
      _spotifyClient.skipPrevious();
    }
  }

  void _playOrPause() {
    final SpotifyPlayerState currentState = _playerStateListener.currentValue;
    if (currentState.track == null) return;

    if (currentState.isPaused) {
      _spotifyClient.resume();
    } else {
      _spotifyClient.pause();
    }
  }

  void _skipNext() {
    final SpotifyPlayerState currentState = _playerStateListener.currentValue;
    if (currentState.track != null &&
        currentState.playbackRestrictions.canSkipNext) {
      _spotifyClient.skipNext();
    }
  }
}
