import 'package:flutter/widgets.dart';

abstract class AppTextStyles {
  static const String fontFamily = 'Maison Neue';

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle titleRegular = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle labelNormal = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w300,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
  );
}
