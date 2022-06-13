// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_player_restrictions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpotifyPlayerRestrictions _$SpotifyPlayerRestrictionsFromJson(
        Map<String, dynamic> json) =>
    SpotifyPlayerRestrictions(
      canRepeatContext: json['canRepeatContext'] as bool,
      canRepeatTrack: json['canRepeatTrack'] as bool,
      canSeek: json['canSeek'] as bool,
      canSkipNext: json['canSkipNext'] as bool,
      canSkipPrev: json['canSkipPrev'] as bool,
      canToggleShuffle: json['canToggleShuffle'] as bool,
    );

Map<String, dynamic> _$SpotifyPlayerRestrictionsToJson(
        SpotifyPlayerRestrictions instance) =>
    <String, dynamic>{
      'canRepeatContext': instance.canRepeatContext,
      'canRepeatTrack': instance.canRepeatTrack,
      'canSeek': instance.canSeek,
      'canSkipNext': instance.canSkipNext,
      'canSkipPrev': instance.canSkipPrev,
      'canToggleShuffle': instance.canToggleShuffle,
    };
