package app.iandis.spotify_client

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import app.iandis.spotify_client.client.SpotifyAuthorizationState
import app.iandis.spotify_client.client.SpotifyClient
import app.iandis.spotify_client.client.SpotifyConnectionState
import app.iandis.spotify_client.client.SpotifyTrackState
import app.iandis.spotify_client.entities.TrackState
import app.iandis.spotify_client.extensions.ListItem
import app.iandis.spotify_client.extensions.toMap
import com.spotify.protocol.types.Image
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.reactivex.rxjava3.disposables.Disposable

internal class SpotifyClientPluginChannel(
    private val _activity: Activity,
    private val _context: Context,
    private val _spotifyClient: SpotifyClient
) :
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler {

    private var _spotifyAuthTokenStateListener: Disposable? = null
    private var _eventSinkForAuthTokenState: EventChannel.EventSink? = null

    private var _spotifyConnectionStateListener: Disposable? = null
    private var _eventSinkForConnectionState: EventChannel.EventSink? = null

    private var _spotifyTrackListener: Disposable? = null
    private var _eventSinkForTrackState: EventChannel.EventSink? = null

    override fun onMethodCall(
        @NonNull call: MethodCall,
        @NonNull result: MethodChannel.Result
    ) {
        when (call.method) {
            "isSpotifyInstalled" -> result.success(_spotifyClient.isSpotifyInstalled(_context))
            "requestAuthorization" -> {
                _spotifyClient.requestAuthorization(_activity)
                result.success(true)
            }
            "connect" -> {
                _spotifyClient.disconnect()
                _spotifyClient.connect(_context)
                result.success(true)
            }
            "disconnect" -> {
                _spotifyClient.disconnect()
                result.success(true)
            }
            "currentAuthToken" -> result.success(_spotifyClient.spotifyCurrentAuthToken)
            "currentConnectionState" -> result.success(_spotifyClient.spotifyCurrentConnectionState.ordinal)
            "currentTrack" -> result.success(_spotifyClient.spotifyCurrentTrack?.toMap())
            "playPlaylist" -> {
                val arguments: String? = call.arguments as? String
                if (arguments != null) {
                    _spotifyClient.playPlaylist(arguments)
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
            "playTrack" -> {
                val arguments: String? = call.arguments as? String
                if (arguments != null) {
                    _spotifyClient.playTrack(arguments)
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
            "pause" -> {
                _spotifyClient.pause()
                result.success(true)
            }
            "resume" -> {
                _spotifyClient.resume()
                result.success(true)
            }
            "skipNext" -> {
                _spotifyClient.skipNext()
                result.success(true)
            }
            "skipPrevious" -> {
                _spotifyClient.skipPrevious()
                result.success(true)
            }
            "getImage" -> {
                val arguments: Map<*, *>? = call.arguments as? Map<*, *>
                if (arguments != null) {
                    val imageUri: String? = arguments["imageUri"] as? String?
                    val imageDimension: Int? = arguments["imageDimension"] as? Int?
                    val dimension: Image.Dimension? = if (imageDimension != null) {
                        Image.Dimension.values().first { it.value == imageDimension }
                    } else null
                    _spotifyClient.getImage(
                        imageUri, dimension,
                        {
                            result.success(it)
                        },
                        {
                            result.error(
                                "SPOTIFY_GET_IMAGE_ERROR",
                                it.cause.toString(),
                                it.toString()
                            )
                        },
                    )
                } else {
                    result.error(
                        "SPOTIFY_GET_IMAGE_ERROR",
                        "Failed to get arguments.",
                        ""
                    )
                }
            }
            "getContentRecommendations" -> {
                _spotifyClient.getContentRecommendations(
                    {
                        result.success(it.toMap())
                    },
                    {
                        result.error(
                            "SPOTIFY_CONTENT_RECOMMENDATION_ERROR",
                            it.cause.toString(),
                            it.toString()
                        )
                    },
                )
            }
            "getContentChildren" -> {
                val arguments: Map<*, *>? = call.arguments as? Map<*, *>
                if (arguments != null) {
                    val limit: Int = arguments["limit"] as? Int ?: 10
                    val offset: Int = arguments["offset"] as? Int ?: 0
                    val itemMap: Map<String, Any?> = arguments["item"] as Map<String, Any?>
                    _spotifyClient.getContentChildren(
                        ListItem.from(itemMap), limit, offset,
                        {
                            result.success(it.toMap())
                        },
                        {
                            result.error(
                                "SPOTIFY_CONTENT_CHILDREN_ERROR",
                                it.cause.toString(),
                                it.toString()
                            )
                        },
                    )
                } else {
                    result.error(
                        "SPOTIFY_CONTENT_CHILDREN_ERROR",
                        "Failed to get arguments.",
                        ""
                    )
                }
            }
            "playContent" -> {
                val arguments: Map<String, Any?>? = call.arguments as? Map<String, Any?>
                if (arguments != null) {
                    _spotifyClient.playContent(ListItem.from(arguments))
                    result.success(true)
                } else {
                    result.error(
                        "SPOTIFY_PLAY_CONTENT_ERROR",
                        "Failed to get arguments.",
                        ""
                    )
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        when (arguments) {
            "onAuthTokenChanged" -> _registerAuthTokenListener(events)
            "onConnectionStateChanged" -> _registerConnectionStateListener(events)
            "onTrackChanged" -> _registerTrackStateListener(events)
            else -> {
                Log.e("spotify_plugin_channel", "Unknown event name: $arguments")
                events?.error(
                    "SPOTIFY_PLUGIN_EVENT_ERROR",
                    "Unknown event name: $arguments",
                    "Please use existing event names."
                )
                events?.endOfStream()
            }
        }
    }

    private fun _registerAuthTokenListener(eventSink: EventChannel.EventSink?) {
        _unregisterAuthTokenListener()
        _eventSinkForAuthTokenState = eventSink
        _spotifyAuthTokenStateListener = _spotifyClient.spotifyAuthorizationState.subscribe {
            when (it) {
                is SpotifyAuthorizationState.Error -> _eventSinkForAuthTokenState?.error(
                    "SPOTIFY_AUTHORIZATION_ERROR",
                    "Authorization error.",
                    it.error
                )
                else -> {
                    val token: String? =
                        if (it is SpotifyAuthorizationState.Authorized) it.token else null
                    _eventSinkForAuthTokenState?.success(token)
                }
            }

        }
    }

    private fun _registerConnectionStateListener(eventSink: EventChannel.EventSink?) {
        _unregisterConnectionStateListener()
        _eventSinkForConnectionState = eventSink
        _spotifyConnectionStateListener = _spotifyClient.spotifyConnectionState.subscribe {
            when (it) {
                is SpotifyConnectionState.Error -> _eventSinkForConnectionState?.error(
                    "SPOTIFY_CONNECTION_ERROR",
                    "Connection error.",
                    it.error
                )
                else -> _eventSinkForConnectionState?.success(it.ordinal)
            }
        }
    }

    private fun _registerTrackStateListener(eventSink: EventChannel.EventSink?) {
        _unregisterTrackStateListener()
        _eventSinkForTrackState = eventSink
        _spotifyTrackListener = _spotifyClient.spotifyTrackState.subscribe {
            val trackState: TrackState? =
                if (it is SpotifyTrackState.Playing) it.trackState else null
            _eventSinkForTrackState?.success(trackState?.toMap())
        }
    }

    override fun onCancel(arguments: Any?) {
        when (arguments) {
            "onAuthTokenChanged" -> _unregisterAuthTokenListener()
            "onConnectionStateChanged" -> _unregisterConnectionStateListener()
            "onTrackChanged" -> _unregisterTrackStateListener()
        }
    }

    private fun _unregisterAuthTokenListener() {
        _spotifyAuthTokenStateListener?.dispose()
        _spotifyAuthTokenStateListener = null

        _eventSinkForAuthTokenState?.endOfStream()
        _eventSinkForAuthTokenState = null
    }

    private fun _unregisterConnectionStateListener() {
        _spotifyConnectionStateListener?.dispose()
        _spotifyConnectionStateListener = null

        _eventSinkForConnectionState?.endOfStream()
        _eventSinkForConnectionState = null
    }

    private fun _unregisterTrackStateListener() {
        _spotifyTrackListener?.dispose()
        _spotifyTrackListener = null

        _eventSinkForTrackState?.endOfStream()
        _eventSinkForTrackState = null
    }

    fun dispose() {
        _unregisterAuthTokenListener()
        _unregisterConnectionStateListener()
        _unregisterTrackStateListener()
    }
}