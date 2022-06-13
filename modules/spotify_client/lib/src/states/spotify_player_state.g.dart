// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_player_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpotifyPlayerState _$SpotifyPlayerStateFromJson(Map<String, dynamic> json) =>
    SpotifyPlayerState(
      isPaused: json['isPaused'] as bool,
      playbackPosition: json['playbackPosition'] as int,
      playbackRestrictions: SpotifyPlayerRestrictions.fromJson(
          castFromNativeMap(json, 'playbackRestrictions')
              as Map<String, dynamic>),
      track: castFromNativeMap(json, 'track') == null
          ? null
          : Track.fromJson(
              castFromNativeMap(json, 'track') as Map<String, dynamic>),
    );

Map<String, dynamic> _$SpotifyPlayerStateToJson(SpotifyPlayerState instance) =>
    <String, dynamic>{
      'isPaused': instance.isPaused,
      'playbackPosition': instance.playbackPosition,
      'playbackRestrictions': instance.playbackRestrictions,
      'track': instance.track,
    };
