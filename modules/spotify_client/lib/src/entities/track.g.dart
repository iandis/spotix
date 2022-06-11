// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Track _$TrackFromJson(Map<String, dynamic> json) => Track(
      uri: json['uri'] as String,
      name: json['name'] as String,
      duration: json['duration'] as int,
      imageUri: json['imageUri'] as String,
      album: Album.fromJson(
          castFromNativeMap(json, 'album') as Map<String, dynamic>),
      artist: Artist.fromJson(
          castFromNativeMap(json, 'artist') as Map<String, dynamic>),
      artists: _artistListFromJson(json['artists']),
    );

Map<String, dynamic> _$TrackToJson(Track instance) => <String, dynamic>{
      'uri': instance.uri,
      'name': instance.name,
      'duration': instance.duration,
      'imageUri': instance.imageUri,
      'album': instance.album,
      'artist': instance.artist,
      'artists': instance.artists,
    };
