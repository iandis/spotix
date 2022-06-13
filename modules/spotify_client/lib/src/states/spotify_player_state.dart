import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:spotify_client/src/entities/map_converter.dart';
import 'package:spotify_client/src/entities/track.dart';
import 'package:spotify_client/src/states/spotify_player_restrictions.dart';

part 'spotify_player_state.g.dart';

@JsonSerializable()
class SpotifyPlayerState with EquatableMixin {
  const SpotifyPlayerState({
    required this.isPaused,
    required this.playbackPosition,
    required this.playbackRestrictions,
    required this.track,
  });

  static const SpotifyPlayerState defaultValue = SpotifyPlayerState(
    isPaused: true,
    playbackPosition: 0,
    playbackRestrictions: SpotifyPlayerRestrictions.defaultValue,
    track: null,
  );

  factory SpotifyPlayerState.fromJson(Map<String, dynamic> json) =>
      _$SpotifyPlayerStateFromJson(json);

  final bool isPaused;

  /// playback position in milliseconds
  final int playbackPosition;

  @JsonKey(readValue: castFromNativeMap)
  final SpotifyPlayerRestrictions playbackRestrictions;

  @JsonKey(readValue: castFromNativeMap)
  final Track? track;

  Map<String, dynamic> get toJson => _$SpotifyPlayerStateToJson(this);

  @override
  List<Object?> get props => <Object?>[
        isPaused,
        playbackPosition,
        playbackRestrictions,
        track,
      ];
}
