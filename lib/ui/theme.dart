import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBeer = Color(0xFFF28E1C);
  static const Color deepAmber = Color(0xFFD97904);
  static const Color foamWhite = Color(0xFFF2F2F2);
  static const Color darkStout = Color(0xFF1A1A1A);
  static const Color glassGlass = Color(0x33FFFFFF);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBeer,
      brightness: Brightness.dark,
      primary: primaryBeer,
      secondary: deepAmber,
      surface: darkStout,
    ),
    scaffoldBackgroundColor: darkStout,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}
