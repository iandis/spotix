import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotix/app_colors.dart';
import 'package:spotix/app_text_styles.dart';

abstract class AppThemes {
  static final ThemeData light = ThemeData(
    primarySwatch: AppColors.primarySwatch,
    fontFamily: AppTextStyles.fontFamily,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      shadowColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
  );

  static final ThemeData dark = ThemeData(
    fontFamily: AppTextStyles.fontFamily,
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      shadowColor: Colors.transparent,
    ),
  );
}
