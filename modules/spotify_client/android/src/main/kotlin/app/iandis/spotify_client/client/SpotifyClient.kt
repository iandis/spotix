package app.iandis.spotify_client.client

import android.app.Activity
import android.content.Context
import app.iandis.spotify_client.entities.TrackState
import com.spotify.protocol.client.CallResult
import com.spotify.protocol.client.ErrorCallback
import com.spotify.protocol.types.Image
import com.spotify.protocol.types.ListItem
import com.spotify.protocol.types.ListItems

import com.spotify.protocol.types.Track
import io.flutter.plugin.common.PluginRegistry
import io.reactivex.rxjava3.core.Observable

sealed class SpotifyAuthorizationState {
    class Authorized(val token: String) : SpotifyAuthorizationState()
    object Unauthorized : SpotifyAuthorizationState()
    class Error(val error: String) : SpotifyAuthorizationState()
}

sealed class SpotifyConnectionState(val ordinal: Int) {
    object Connected : SpotifyConnectionState(0)
    object Connecting : SpotifyConnectionState(1)
    object Disconnected : SpotifyConnectionState(2)
    class Error(val error: String) : SpotifyConnectionState(3)
}

sealed class SpotifyTrackState {
    class Playing(val trackState: TrackState) : SpotifyTrackState()
    object None : SpotifyTrackState()
}

interface SpotifyClient : PluginRegistry.ActivityResultListener {

    companion object {
        fun create(clientId: String, redirectUri: String): SpotifyClient {
            return SpotifyClientImpl(clientId, redirectUri)
        }
    }

    val spotifyAuthorizationState: Observable<SpotifyAuthorizationState>

    val spotifyCurrentAuthToken: String?

    val spotifyConnectionState: Observable<SpotifyConnectionState>

    val spotifyCurrentConnectionState: SpotifyConnectionState

    val spotifyTrackState: Observable<SpotifyTrackState>

    val spotifyCurrentTrack: Track?

    fun isSpotifyInstalled(context: Context): Boolean

    fun requestAuthorization(activity: Activity)

    fun connect(context: Context)

    fun disconnect()

    fun playPlaylist(playlistId: String)

    fun playTrack(trackId: String)

    fun pause()

    fun resume()

    fun skipNext()

    fun skipPrevious()

    fun getImage(
        imageUri: String?,
        imageDimension: Image.Dimension?,
        onResult: CallResult.ResultCallback<ByteArray?>,
        onError: ErrorCallback
    )

    fun getContentRecommendations(
        onResult: CallResult.ResultCallback<ListItems>,
        onError: ErrorCallback
    )

    fun getContentChildren(
        item: ListItem,
        limit: Int,
        offset: Int,
        onResult: CallResult.ResultCallback<ListItems>,
        onError: ErrorCallback
    )

    fun playContent(item: ListItem)

    fun dispose()
}