import 'package:flutter/material.dart';
import 'package:spotix/offline_storage.dart';

class AppThemeController extends ChangeNotifier {
  AppThemeController(this._offlineStorage);

  final OfflineStorage _offlineStorage;

  bool get isDarkMode {
    return _offlineStorage.isDarkMode ??
        WidgetsBinding.instance!.window.platformBrightness == Brightness.dark;
  }

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleDarkMode() {
    _offlineStorage.setDarkMode(!isDarkMode);
    notifyListeners();
  }
}
