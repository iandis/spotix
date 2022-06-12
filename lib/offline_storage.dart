import 'package:shared_preferences/shared_preferences.dart';

class OfflineStorage {
  const OfflineStorage(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  bool? get isDarkMode => _sharedPreferences.getBool('dark_mode');

  void setDarkMode(bool value) {
    _sharedPreferences.setBool('dark_mode', value);
  }
}
