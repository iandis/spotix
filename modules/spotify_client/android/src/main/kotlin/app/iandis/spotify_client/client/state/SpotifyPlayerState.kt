package app.iandis.spotify_client.client.state

import app.iandis.spotify_client.extensions.toMap
import com.spotify.protocol.types.PlayerState

sealed class SpotifyPlayerState {
    class Value(private val playerState: PlayerState) : SpotifyPlayerState() {
        fun toMap(): Map<String, Any?> {
            return playerState.toMap()
        }
    }
    class Error(val error: Throwable) : SpotifyPlayerState()
    object None : SpotifyPlayerState()
}