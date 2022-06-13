package app.iandis.spotify_client

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import app.iandis.spotify_client.client.*
import app.iandis.spotify_client.client.state.SpotifyAuthorizationState
import app.iandis.spotify_client.client.state.SpotifyConnectionState
import app.iandis.spotify_client.client.state.SpotifyPlayerState
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

    private var _spotifyAuthorizationStateListener: Disposable? = null
    private var _eventSinkForAuthorizationState: EventChannel.EventSink? = null

    private var _spotifyConnectionStateListener: Disposable? = null
    private var _eventSinkForConnectionState: EventChannel.EventSink? = null

    private var _spotifyPlayerStateListener: Disposable? = null
    private var _eventSinkForPlayerState: EventChannel.EventSink? = null

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
                _spotifyClient.connect(_context)
                result.success(true)
            }
            "disconnect" -> {
                _spotifyClient.disconnect()
                result.success(true)
            }
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
            "onAuthorizationStateChanged" -> _registerAuthorizationStateListener(events)
            "onConnectionStateChanged" -> _registerConnectionStateListener(events)
            "onPlayerStateChanged" -> _registerPlayerStateListener(events)
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

    private fun _registerAuthorizationStateListener(eventSink: EventChannel.EventSink?) {
        _unregisterAuthorizationStateListener()
        _eventSinkForAuthorizationState = eventSink
        _spotifyAuthorizationStateListener = _spotifyClient.spotifyAuthorizationState.subscribe {
            when (it) {
                is SpotifyAuthorizationState.Error -> _eventSinkForAuthorizationState?.error(
                    "SPOTIFY_AUTHORIZATION_ERROR",
                    "Authorization error.",
                    it.error
                )
                else -> _eventSinkForAuthorizationState?.success(it.toMap())
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

    private fun _registerPlayerStateListener(eventSink: EventChannel.EventSink?) {
        _unregisterPlayerStateListener()
        _eventSinkForPlayerState = eventSink
        _spotifyPlayerStateListener = _spotifyClient.spotifyPlayerState.subscribe {
            when (it) {
                is SpotifyPlayerState.Error -> _eventSinkForPlayerState?.error(
                    "SPOTIFY_PLAYER_ERROR",
                    "Player error.",
                    it.error
                )
                else -> {
                    val spotifyPlayerState: Map<String, Any?>? =
                        if (it is SpotifyPlayerState.Value) it.toMap() else null
                    _eventSinkForPlayerState?.success(spotifyPlayerState)
                }
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        when (arguments) {
            "onAuthorizationStateChanged" -> _unregisterAuthorizationStateListener()
            "onConnectionStateChanged" -> _unregisterConnectionStateListener()
            "onPlayerStateChanged" -> _unregisterPlayerStateListener()
        }
    }

    private fun _unregisterAuthorizationStateListener() {
        _spotifyAuthorizationStateListener?.dispose()
        _spotifyAuthorizationStateListener = null

        _eventSinkForAuthorizationState?.endOfStream()
        _eventSinkForAuthorizationState = null
    }

    private fun _unregisterConnectionStateListener() {
        _spotifyConnectionStateListener?.dispose()
        _spotifyConnectionStateListener = null

        _eventSinkForConnectionState?.endOfStream()
        _eventSinkForConnectionState = null
    }

    private fun _unregisterPlayerStateListener() {
        _spotifyPlayerStateListener?.dispose()
        _spotifyPlayerStateListener = null

        _eventSinkForPlayerState?.endOfStream()
        _eventSinkForPlayerState = null
    }

    fun dispose() {
        _unregisterAuthorizationStateListener()
        _unregisterConnectionStateListener()
        _unregisterPlayerStateListener()
    }
}