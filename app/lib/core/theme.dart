import 'package:flutter/material.dart';

class AppTheme {
  // Dark mode palette
  static const Color darkPrimary = Color(0xFF00E5FF); // Teal / Cyan
  static const Color darkBackground = Color(0xFF12181F); // Deep dark slate
  static const Color darkSurface = Color(0xFF1E2630); // Dark slate
  static const Color darkSurfaceVariant = Color(0xFF283340);
  static const Color darkError = Color(0xFFFF5252); // Bright red / coral
  static const Color darkSuccess = Color(0xFF00E676); // Vibrant green
  static const Color darkWarning = Color(0xFFFFB74D); // Warm amber
  static const Color darkTextPrimary = Color(0xFFE2E8F0);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkOnSurface = Color(0xFFE2E8F0);
  static const Color darkOnBackground = Color(0xFFE2E8F0);

  // Light mode palette
  static const Color lightPrimary = Color(0xFF00838F); // Dark teal
  static const Color lightBackground = Color(0xFFF8FAFC); // Clean slate white
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEEF2F6);
  static const Color lightError = Color(0xFFD32F2F);
  static const Color lightOnSurface = Color(0xFF0F172A);
  static const Color lightOnBackground = Color(0xFF0F172A);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: Color(0xFF26C6DA),
        surface: darkSurface,
        error: darkError,
        onPrimary: Color(0xFF00363A),
        onSecondary: Color(0xFF00363A),
        onSurface: darkOnSurface,
        onError: Colors.white,
      ),
      cardTheme: const CardThemeData(
        color: darkSurface,
        elevation: 2,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkOnBackground,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: Color(0xFF0097A7),
        surface: lightSurface,
        error: lightError,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightOnSurface,
        onError: Colors.white,
      ),
      cardTheme: const CardThemeData(
        color: lightSurface,
        elevation: 1,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightOnBackground,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
