// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackState _$TrackStateFromJson(Map<String, dynamic> json) => TrackState(
      isPaused: json['isPaused'] as bool,
      track: Track.fromJson(
          castFromNativeMap(json, 'track') as Map<String, dynamic>),
    );

Map<String, dynamic> _$TrackStateToJson(TrackState instance) =>
    <String, dynamic>{
      'isPaused': instance.isPaused,
      'track': instance.track,
    };
