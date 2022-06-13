import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify_client/spotify_client.dart';
import 'package:spotix/app_theme_controller.dart';
import 'package:spotix/cached_image_bytes_manager.dart';
import 'package:spotix/content_provider.dart';
import 'package:spotix/listeners/auth_state_listener.dart';
import 'package:spotix/listeners/connection_state_listener.dart';
import 'package:spotix/listeners/player_state_listener.dart';
import 'package:spotix/offline_storage.dart';

final GetIt getIt = GetIt.I;

Future<void> initDI() async {
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

  getIt
    ..registerSingleton<SpotifyClient>(const SpotifyClient())
    ..registerSingleton<AuthStateListener>(
      AuthStateListener(getIt<SpotifyClient>()),
    )
    ..registerSingleton<ConnectionStateListener>(
      ConnectionStateListener(getIt<SpotifyClient>()),
    )
    ..registerSingleton<PlayerStateListener>(
      PlayerStateListener(getIt<SpotifyClient>()),
    )
    ..registerSingleton<SharedPreferences>(sharedPreferences)
    ..registerSingleton<OfflineStorage>(
      OfflineStorage(getIt<SharedPreferences>()),
    )
    ..registerSingleton<AppThemeController>(
      AppThemeController(getIt<OfflineStorage>()),
    )
    ..registerSingleton<CachedImageBytesManager>(CachedImageBytesManager())
    ..registerSingleton<ContentProvider>(
      ContentProvider(
        getIt<CachedImageBytesManager>(),
        getIt<ConnectionStateListener>(),
        getIt<SpotifyClient>(),
      ),
    );
}
