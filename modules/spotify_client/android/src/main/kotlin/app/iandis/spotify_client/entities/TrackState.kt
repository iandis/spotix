package app.iandis.spotify_client.entities

import app.iandis.spotify_client.extensions.toMap
import com.spotify.protocol.types.Track

data class TrackState(val isPaused: Boolean, val track: Track) {
    fun toMap(): Map<String, Any?> {
        val trackStateMap: MutableMap<String, Any?> = mutableMapOf()
        trackStateMap["isPaused"] = isPaused
        trackStateMap["track"] = track.toMap()
        return trackStateMap
    }
}
