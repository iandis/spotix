package app.iandis.spotify_client.client

import android.app.Activity
import android.content.Context
import app.iandis.spotify_client.client.state.SpotifyAuthorizationState
import app.iandis.spotify_client.client.state.SpotifyConnectionState
import app.iandis.spotify_client.client.state.SpotifyPlayerState
import com.spotify.protocol.client.CallResult
import com.spotify.protocol.client.ErrorCallback
import com.spotify.protocol.types.*

import io.flutter.plugin.common.PluginRegistry
import io.reactivex.rxjava3.core.Observable

interface SpotifyClient : PluginRegistry.ActivityResultListener {

    companion object {
        fun create(clientId: String, redirectUri: String): SpotifyClient {
            return SpotifyClientImpl(clientId, redirectUri)
        }
    }

    val spotifyAuthorizationState: Observable<SpotifyAuthorizationState>

    val spotifyConnectionState: Observable<SpotifyConnectionState>

    val spotifyPlayerState: Observable<SpotifyPlayerState>

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