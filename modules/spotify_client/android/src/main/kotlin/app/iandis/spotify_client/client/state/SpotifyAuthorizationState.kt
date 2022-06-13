package app.iandis.spotify_client.client.state

sealed class SpotifyAuthorizationState(private val ordinal: Int) {
    class Authorized(val token: String) : SpotifyAuthorizationState(0)
    object Authorizing : SpotifyAuthorizationState(1)
    object Unauthorized : SpotifyAuthorizationState(2)
    class Error(val error: String) : SpotifyAuthorizationState(3)

    fun toMap(): Map<String, Any?> {
        val authMap: MutableMap<String, Any?> = mutableMapOf()
        val authToken: String? = if (this is Authorized) token else null
        authMap["status"] = ordinal
        authMap["token"] = authToken
        return authMap
    }
}