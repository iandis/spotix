import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotix/app_env.dart';

import 'package:spotix/app_theme_controller.dart';
import 'package:spotix/app_themes.dart';
import 'package:spotix/content_provider.dart';
import 'package:spotix/di.dart';
import 'package:spotix/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDI();

  runApp(
    ChangeNotifierProvider<AppThemeController>(
      create: (_) => getIt<AppThemeController>(),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeController>(
      builder: (_, __, ___) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          restorationScopeId: 'spotix-${AppEnv.versionName}',
          title: 'Spotix',
          themeMode: context.read<AppThemeController>().themeMode,
          theme: AppThemes.light,
          darkTheme: AppThemes.dark,
          home: ChangeNotifierProvider<ContentProvider>(
            create: (_) => getIt<ContentProvider>(),
            child: const HomePage(),
          ),
        );
      },
    );
  }
}
