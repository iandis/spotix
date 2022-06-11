import 'package:json_annotation/json_annotation.dart';
import 'package:spotify_client/src/entities/map_converter.dart';
import 'package:spotify_client/src/entities/track.dart';

part 'track_state.g.dart';

@JsonSerializable()
class TrackState {
  const TrackState({
    required this.isPaused,
    required this.track,
  });

  factory TrackState.fromJson(Map<String, dynamic> json) =>
      _$TrackStateFromJson(json);

  final bool isPaused;

  @JsonKey(readValue: castFromNativeMap)
  final Track track;

  Map<String, dynamic> get toJson => _$TrackStateToJson(this);
}
