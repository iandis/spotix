import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'spotify_player_restrictions.g.dart';

@JsonSerializable()
class SpotifyPlayerRestrictions with EquatableMixin {
  const SpotifyPlayerRestrictions({
    required this.canRepeatContext,
    required this.canRepeatTrack,
    required this.canSeek,
    required this.canSkipNext,
    required this.canSkipPrev,
    required this.canToggleShuffle,
  });

  static const SpotifyPlayerRestrictions defaultValue =
      SpotifyPlayerRestrictions(
    canRepeatContext: false,
    canRepeatTrack: false,
    canSeek: false,
    canSkipNext: false,
    canSkipPrev: false,
    canToggleShuffle: false,
  );

  factory SpotifyPlayerRestrictions.fromJson(Map<String, dynamic> json) =>
      _$SpotifyPlayerRestrictionsFromJson(json);

  final bool canRepeatContext;

  final bool canRepeatTrack;

  final bool canSeek;

  final bool canSkipNext;

  final bool canSkipPrev;

  final bool canToggleShuffle;

  Map<String, dynamic> get toJson => _$SpotifyPlayerRestrictionsToJson(this);

  @override
  List<Object?> get props => <Object?>[
        canRepeatContext,
        canRepeatTrack,
        canSeek,
        canSkipNext,
        canSkipPrev,
        canToggleShuffle,
      ];
}
