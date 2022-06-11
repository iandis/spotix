package app.iandis.spotify_client.extensions

import com.spotify.protocol.types.Album
import com.spotify.protocol.types.Artist
import com.spotify.protocol.types.ImageUri
import com.spotify.protocol.types.Track

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