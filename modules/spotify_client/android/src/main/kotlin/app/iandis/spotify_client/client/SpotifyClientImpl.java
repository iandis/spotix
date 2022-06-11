package app.iandis.spotify_client.client;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.spotify.android.appremote.api.ConnectionParams;
import com.spotify.android.appremote.api.Connector;
import com.spotify.android.appremote.api.ContentApi;
import com.spotify.android.appremote.api.SpotifyAppRemote;
import com.spotify.protocol.client.CallResult;
import com.spotify.protocol.client.ErrorCallback;
import com.spotify.protocol.client.Subscription;
import com.spotify.protocol.types.Image;
import com.spotify.protocol.types.ImageUri;
import com.spotify.protocol.types.ListItem;
import com.spotify.protocol.types.ListItems;
import com.spotify.protocol.types.PlayerState;
import com.spotify.protocol.types.Track;
import com.spotify.sdk.android.auth.AuthorizationClient;
import com.spotify.sdk.android.auth.AuthorizationRequest;
import com.spotify.sdk.android.auth.AuthorizationResponse;

import java.io.ByteArrayOutputStream;
import java.util.Objects;

import app.iandis.spotify_client.entities.TrackState;
import io.reactivex.rxjava3.core.Observable;
import io.reactivex.rxjava3.subjects.BehaviorSubject;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;

class SpotifyClientImpl implements
        SpotifyClient, Connector.ConnectionListener,
        Subscription.EventCallback<PlayerState> {

    private static final String TAG = "spotify_client";

    private static final int _spotifyAuthorizationRequestCode = 23941;

    private static final String[] _spotifyAuthorizationScopes = new String[]{
            "app-remote-control",
            "playlist-read-private",
            "playlist-read-collaborative",
            "user-library-read"
    };

    SpotifyClientImpl(@NonNull String clientId, @NonNull String redirectUri) {
        this._spotifyAuthorizationRequest = new AuthorizationRequest.Builder(
                clientId, AuthorizationResponse.Type.TOKEN, redirectUri)
                .setScopes(_spotifyAuthorizationScopes)
                .build();

        this._spotifyConnectionParams = new ConnectionParams.Builder(clientId)
                .setRedirectUri(redirectUri)
                .build();
    }

    private final AuthorizationRequest _spotifyAuthorizationRequest;

    private final ConnectionParams _spotifyConnectionParams;

    @Nullable
    private SpotifyAppRemote _spotifyAppRemote;

    private final BehaviorSubject<SpotifyAuthorizationState> _spotifyAuthorizationState =
            BehaviorSubject.createDefault(SpotifyAuthorizationState.Unauthorized.INSTANCE);

    @NonNull
    @Override
    public Observable<SpotifyAuthorizationState> getSpotifyAuthorizationState() {
        return _spotifyAuthorizationState;
    }

    @Nullable
    @Override
    public String getSpotifyCurrentAuthToken() {
        final SpotifyAuthorizationState currentState = _spotifyAuthorizationState.getValue();
        if (currentState instanceof SpotifyAuthorizationState.Authorized) {
            return ((SpotifyAuthorizationState.Authorized) currentState).getToken();
        }
        return null;
    }

    private final BehaviorSubject<SpotifyConnectionState> _spotifyConnectionState =
            BehaviorSubject.createDefault(SpotifyConnectionState.Disconnected.INSTANCE);

    @NonNull
    @Override
    public Observable<SpotifyConnectionState> getSpotifyConnectionState() {
        return _spotifyConnectionState;
    }

    @NonNull
    @Override
    public SpotifyConnectionState getSpotifyCurrentConnectionState() {
        return _spotifyConnectionState.getValue();
    }

    private final
    BehaviorSubject<SpotifyTrackState> _spotifyTrackState =
            BehaviorSubject.createDefault(SpotifyTrackState.None.INSTANCE);

    @NonNull
    @Override
    public Observable<SpotifyTrackState> getSpotifyTrackState() {
        return _spotifyTrackState;
    }

    @Nullable
    @Override
    public Track getSpotifyCurrentTrack() {
        final SpotifyTrackState currentState = _spotifyTrackState.getValue();
        if (currentState instanceof SpotifyTrackState.Playing) {
            return ((SpotifyTrackState.Playing) currentState).getTrackState().getTrack();
        }
        return null;
    }

    /**
     * This is for handling successful spotify connection
     */
    @Override
    public void onConnected(SpotifyAppRemote spotifyAppRemote) {
        _spotifyAppRemote = spotifyAppRemote;
        _spotifyAppRemote.getPlayerApi().subscribeToPlayerState().setEventCallback(this);
        _spotifyConnectionState.onNext(SpotifyConnectionState.Connected.INSTANCE);

        Log.i(TAG, "Connected to spotify app remote.");
    }

    /**
     * This is for handling spotify player state events
     */
    @Override
    public void onEvent(PlayerState data) {
        final Track track = data.track;
        final SpotifyTrackState nextState = track != null
                ? new SpotifyTrackState.Playing(new TrackState(data.isPaused, track))
                : SpotifyTrackState.None.INSTANCE;
        _spotifyTrackState.onNext(nextState);
    }

    /**
     * This is for handling spotify connection failure
     */
    @Override
    public void onFailure(Throwable error) {
        final String errorMsg = error.toString();
        Log.d(TAG, "Failed to connect spotify app remote: err=".concat(errorMsg));
        _spotifyConnectionState.onNext(new SpotifyConnectionState.Error(errorMsg));
    }

    /**
     * This is for handling spotify authorization activity
     */
    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode != _spotifyAuthorizationRequestCode) return false;

        final AuthorizationResponse response =
                AuthorizationClient.getResponse(resultCode, data);
        switch (response.getType()) {
            case TOKEN:
                _spotifyAuthorizationState.onNext(
                        new SpotifyAuthorizationState.Authorized(response.getAccessToken()));
                break;
            case ERROR:
                _spotifyAuthorizationState.onNext(
                        new SpotifyAuthorizationState.Error(response.getError()));
                break;
            default:
        }

        return true;
    }

    @Override
    public boolean isSpotifyInstalled(@NonNull Context context) {
        return SpotifyAppRemote.isSpotifyInstalled(context);
    }

    @Override
    public void requestAuthorization(@NonNull Activity activity) {
        AuthorizationClient.openLoginActivity(
                activity, _spotifyAuthorizationRequestCode, _spotifyAuthorizationRequest);
    }

    @Override
    public void connect(@NonNull Context context) {
        SpotifyAppRemote.connect(context, _spotifyConnectionParams, this);
    }

    @Override
    public void disconnect() {
        if (_spotifyAppRemote == null || !_spotifyAppRemote.isConnected()) return;
        SpotifyAppRemote.disconnect(_spotifyAppRemote);
        _spotifyAppRemote = null;
        _spotifyAuthorizationState.onNext(SpotifyAuthorizationState.Unauthorized.INSTANCE);
        _spotifyConnectionState.onNext(SpotifyConnectionState.Disconnected.INSTANCE);
        _spotifyTrackState.onNext(SpotifyTrackState.None.INSTANCE);
    }

    @Override
    public void playPlaylist(@NonNull String playlistId) {
        _play("spotify:playlist:".concat(playlistId));
    }

    @Override
    public void playTrack(@NonNull String trackId) {
        _play("spotify:track:".concat(trackId));
    }

    private void _play(@NonNull String spotifyUri) {
        if (_spotifyAppRemote == null) return;
        _spotifyAppRemote.getPlayerApi().play(spotifyUri);
    }

    @Override
    public void pause() {
        if (_spotifyAppRemote == null) return;
        _spotifyAppRemote.getPlayerApi().pause();
    }

    @Override
    public void resume() {
        if (_spotifyAppRemote == null) return;
        _spotifyAppRemote.getPlayerApi().resume();
    }

    @Override
    public void skipNext() {
        if (_spotifyAppRemote == null) return;
        _spotifyAppRemote.getPlayerApi().skipNext();
    }

    @Override
    public void skipPrevious() {
        if (_spotifyAppRemote == null) return;
        _spotifyAppRemote.getPlayerApi().skipPrevious();
    }

    @Override
    public void getImage(
            @Nullable String imageUri,
            @Nullable Image.Dimension imageDimension,
            @NonNull CallResult.ResultCallback<byte[]> onResult,
            @NonNull ErrorCallback onError
    ) {
        if (_spotifyAppRemote == null) return;
        if (imageUri == null) {
            onResult.onResult(null);
            return;
        }
        final Image.Dimension dimension = imageDimension == null
                ? Image.Dimension.THUMBNAIL
                : imageDimension;
        _spotifyAppRemote
                .getImagesApi()
                .getImage(new ImageUri(imageUri), dimension)
                .setResultCallback((Bitmap bitmap) -> {
                    final ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                    bitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
                    onResult.onResult(byteArrayOutputStream.toByteArray());
                })
                .setErrorCallback(onError);

    }

    @Override
    public void getContentRecommendations(
            @NonNull CallResult.ResultCallback<ListItems> onResult,
            @NonNull ErrorCallback onError
    ) {
        if (_spotifyAppRemote == null) return;
        _spotifyAppRemote
                .getContentApi()
                .getRecommendedContentItems(ContentApi.ContentType.DEFAULT)
                .setResultCallback(onResult)
                .setErrorCallback(onError);
    }

    @Override
    public void dispose() {
        _spotifyAuthorizationState.onComplete();
        _spotifyConnectionState.onComplete();
        _spotifyTrackState.onComplete();
    }


    @Override
    public void getContentChildren(
            @NonNull ListItem item,
            int limit,
            int offset,
            @NonNull CallResult.ResultCallback<ListItems> onResult,
            @NonNull ErrorCallback onError
    ) {
        if (_spotifyAppRemote == null) return;
        _spotifyAppRemote
                .getContentApi()
                .getChildrenOfItem(item, limit, offset)
                .setResultCallback(onResult)
                .setErrorCallback(onError);
    }

    @Override
    public void playContent(@NonNull ListItem item) {
        if (_spotifyAppRemote == null || !item.playable) return;
        _spotifyAppRemote
                .getContentApi()
                .playContentItem(item);
    }

}