package app.iandis.spotify_client.client.state

sealed class SpotifyConnectionState(val ordinal: Int) {
    object Connected : SpotifyConnectionState(0)
    object Connecting : SpotifyConnectionState(1)
    object Disconnected : SpotifyConnectionState(2)
    class Error(val error: String) : SpotifyConnectionState(3)
}