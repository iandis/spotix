package app.iandis.spotify_client.extensions

import com.spotify.protocol.types.*

fun PlayerState.toMap(): Map<String, Any?> {
    val playerStateMap: MutableMap<String, Any?> = mutableMapOf()
    playerStateMap["isPaused"] = isPaused
    playerStateMap["playbackPosition"] = playbackPosition
    playerStateMap["playbackRestrictions"] = playbackRestrictions?.toMap()
    playerStateMap["track"] = track?.toMap()
    return playerStateMap
}

fun PlayerRestrictions.toMap(): Map<String, Any?> {
    val playerRestrictionsMap: MutableMap<String, Any?> = mutableMapOf()
    playerRestrictionsMap["canRepeatContext"] = canRepeatContext
    playerRestrictionsMap["canRepeatTrack"] = canRepeatTrack
    playerRestrictionsMap["canSeek"] = canSeek
    playerRestrictionsMap["canSkipNext"] = canSkipNext
    playerRestrictionsMap["canSkipPrev"] = canSkipPrev
    playerRestrictionsMap["canToggleShuffle"] = canToggleShuffle
    return playerRestrictionsMap
}

fun Track.toMap(): Map<String, Any?> {
    val trackMap: MutableMap<String, Any?> = mutableMapOf()
    trackMap["uri"] = this.uri
    trackMap["name"] = this.name
    trackMap["duration"] = this.duration
    trackMap["imageUri"] = this.imageUri.raw
    trackMap["album"] = this.album.toMap()
    trackMap["artist"] = this.artist.toMap()
    trackMap["artists"] = this.artists.map { it.toMap() }
    return trackMap
}

fun Album.toMap(): Map<String, Any?> {
    val albumMap: MutableMap<String, Any?> = mutableMapOf()
    albumMap["uri"] = this.uri
    albumMap["name"] = this.name
    return albumMap
}

fun Artist.toMap(): Map<String, Any?> {
    val artistMap: MutableMap<String, Any?> = mutableMapOf()
    artistMap["uri"] = this.uri
    artistMap["name"] = this.name
    return artistMap
}