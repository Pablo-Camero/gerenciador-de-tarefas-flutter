
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData temaClaro = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 49, 140, 214),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  static ThemeData temaEscuro = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 2, 70, 126),
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
