package app.iandis.spotify_client

import android.app.Activity
import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.annotation.NonNull
import app.iandis.spotify_client.client.SpotifyClient

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class SpotifyClientPlugin : FlutterPlugin, ActivityAware {
    private lateinit var _methodChannel: MethodChannel
    private lateinit var _authStateEventChannel: EventChannel
    private lateinit var _connectionStateEventChannel: EventChannel
    private lateinit var _trackStateEventChannel: EventChannel

    private var _activityBinding: ActivityPluginBinding? = null
    private var _pluginBinding: FlutterPlugin.FlutterPluginBinding? = null
    private var _context: Context? = null
    private var _spotifyClient: SpotifyClient? = null
    private var _channel: SpotifyClientPluginChannel? = null

    companion object {
        private const val _methodChannelName: String = "spotify_client_method_channel"
        private const val _eventChannelName: String = "spotify_client_event_channel"
        private const val _authStateEventChannelName: String =
            "$_eventChannelName#onAuthTokenChanged"
        private const val _connectionStateEventChannelName: String =
            "$_eventChannelName#onConnectionStateChanged"
        private const val _trackStateEventChannelName: String = "$_eventChannelName#onTrackChanged"
    }

    override fun onAttachedToEngine(
        @NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding
    ) {
        _pluginBinding = flutterPluginBinding
        _initClient(flutterPluginBinding.applicationContext)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        _activityBinding = binding
        _initChannel(binding.activity)
        binding.addActivityResultListener(_spotifyClient!!)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    private fun _initClient(context: Context) {
        _context = context
        val applicationInfo: ApplicationInfo = context.packageManager.getApplicationInfo(
            context.packageName,
            PackageManager.GET_META_DATA
        )
        val bundle: Bundle = applicationInfo.metaData
        val spotifyClientId: String = bundle["SPOTIFY_CLIENT_ID"] as String
        val spotifyRedirectUri: String = bundle["SPOTIFY_REDIRECT_URI"] as String
        _spotifyClient = SpotifyClient.create(spotifyClientId, spotifyRedirectUri)
    }

    private fun _initChannel(activity: Activity) {
        _channel = SpotifyClientPluginChannel(activity, _context!!, _spotifyClient!!)
        _methodChannel = MethodChannel(_pluginBinding!!.binaryMessenger, _methodChannelName)
        _methodChannel.setMethodCallHandler(_channel!!)

        _authStateEventChannel =
            EventChannel(_pluginBinding!!.binaryMessenger, _authStateEventChannelName)
        _authStateEventChannel.setStreamHandler(_channel!!)

        _connectionStateEventChannel =
            EventChannel(_pluginBinding!!.binaryMessenger, _connectionStateEventChannelName)
        _connectionStateEventChannel.setStreamHandler(_channel!!)

        _trackStateEventChannel =
            EventChannel(_pluginBinding!!.binaryMessenger, _trackStateEventChannelName)
        _trackStateEventChannel.setStreamHandler(_channel!!)
    }

    private fun _destroyChannel() {
        _methodChannel.setMethodCallHandler(null)
        _authStateEventChannel.setStreamHandler(null)
        _connectionStateEventChannel.setStreamHandler(null)
        _trackStateEventChannel.setStreamHandler(null)
        _channel?.dispose()
        _channel = null
        _pluginBinding = null
    }

    private fun _destroyClient() {
        _spotifyClient?.disconnect()
        _spotifyClient?.dispose()
        _spotifyClient = null
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onDetachedFromActivity() {
        _activityBinding?.removeActivityResultListener(_spotifyClient!!)
        _activityBinding = null
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        _destroyChannel()
        _destroyClient()
    }
}
