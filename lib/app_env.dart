import 'package:package_info_plus/package_info_plus.dart';

abstract class AppEnv {
  static Future<void> initialize() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _versionName = packageInfo.version;
  }

  static String _versionName = '';

  static String get versionName => _versionName;
}
