import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spotify_client/spotify_client.dart';
import 'package:spotix/app_colors.dart';
import 'package:spotix/app_text_styles.dart';
import 'package:spotix/di.dart';
import 'package:spotix/extensions/num_extensions.dart';
import 'package:spotix/listeners/player_state_listener.dart';

class TrackPlaybackPositionContainer extends StatefulWidget {
  const TrackPlaybackPositionContainer({Key? key}) : super(key: key);

  @override
  State<TrackPlaybackPositionContainer> createState() =>
      _TrackPlaybackPositionContainerState();
}

class _TrackPlaybackPositionContainerState
    extends State<TrackPlaybackPositionContainer>
    with SingleTickerProviderStateMixin<TrackPlaybackPositionContainer> {
  late final AnimationController _playbackPositionController;

  late final PlayerStateListener _playerStateListener;

  late final StreamSubscription<SpotifyPlayerState>
      _playerStateListenerSubscriber;

  late SpotifyPlayerState _previousState;

  static const Duration _reverseDuration = Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        final double maxWidth = constraints.maxWidth;
        return AnimatedBuilder(
          animation: _playbackPositionController,
          builder: (_, __) {
            final double currentProgress = _playbackPositionController.value;
            final double currentPositionTime =
                currentProgress * (_previousState.track?.duration ?? 0);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: currentProgress * maxWidth,
                  height: 3,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySwatch,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: maxWidth,
                  child: Center(
                    child: Text(
                      currentPositionTime.inTime,
                      style: AppTextStyles.hint,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _playerStateListener = getIt<PlayerStateListener>();
    _initPlaybackPositionController();
  }

  @override
  void dispose() {
    _playerStateListenerSubscriber.cancel();
    _playbackPositionController.dispose();
    super.dispose();
  }

  void _initPlaybackPositionController() {
    final SpotifyPlayerState currentState = _playerStateListener.currentValue;
    _previousState = currentState;
    _playbackPositionController = AnimationController(
      duration: currentState.track == null
          ? Duration.zero
          : Duration(milliseconds: currentState.track!.duration),
      reverseDuration: _reverseDuration,
      value: currentState.track == null
          ? 0
          : currentState.playbackPosition / currentState.track!.duration,
      vsync: this,
    );
    if (!currentState.isPaused) {
      _playbackPositionController.forward();
    }
    _playerStateListenerSubscriber =
        _playerStateListener.onChanged.listen(_onChangePlaybackPosition);
  }

  Future<void> _onChangePlaybackPosition(SpotifyPlayerState state) async {
    final SpotifyPlayerState previousState = _previousState;
    _previousState = state;
    if (state.track == previousState.track) {
      _onUpdatePlaybackPosition(previousState, state);
    } else {
      _onResetPlaybackPosition(state);
    }
  }

  Future<void> _onUpdatePlaybackPosition(
    SpotifyPlayerState oldState,
    SpotifyPlayerState newState,
  ) async {
    if (newState.isPaused && !oldState.isPaused) {
      return _playbackPositionController.stop();
    } else if (!newState.isPaused && oldState.isPaused) {
      _playbackPositionController.forward();
    } else if (newState.track != null && oldState.track != null) {
      if ((newState.playbackPosition - oldState.playbackPosition).abs() > 200) {
        await _playbackPositionController.animateTo(
          newState.playbackPosition / newState.track!.duration,
          duration: _reverseDuration,
          curve: Curves.fastLinearToSlowEaseIn,
        );
      } else {
        _playbackPositionController.value =
            newState.playbackPosition / newState.track!.duration;
      }
      return _playbackPositionController.forward();
    }
  }

  Future<void> _onResetPlaybackPosition(SpotifyPlayerState state) async {
    await _playbackPositionController.animateTo(
      0.0,
      duration: _reverseDuration,
      curve: Curves.fastLinearToSlowEaseIn,
    );
    _playbackPositionController.reset();
    _playbackPositionController
      ..duration = state.track == null
          ? Duration.zero
          : Duration(milliseconds: state.track!.duration)
      ..value = state.track == null
          ? 0
          : state.playbackPosition / state.track!.duration;
    if (state.isPaused) return;
    _playbackPositionController.forward();
  }
}
