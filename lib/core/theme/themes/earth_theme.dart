import 'package:flutter/material.dart';

class EarthTheme {
  EarthTheme._();

  static const Color _primary = Color(0xFF8B4513);
  static const Color _secondary = Color(0xFFD2691E);
  static const Color _background = Color(0xFFFDF5E6);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _onPrimary = Color(0xFFFFFFFF);
  static const Color _onSecondary = Color(0xFFFFFFFF);
  static const Color _onSurface = Color(0xFF3E2723);
  static const Color _error = Color(0xFFB00020);

  static ThemeData get themeData => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: _primary,
      onPrimary: _onPrimary,
      secondary: _secondary,
      onSecondary: _onSecondary,
      error: _error,
      onError: Color(0xFFFFFFFF),
      surface: _surface,
      onSurface: _onSurface,
    ),
    scaffoldBackgroundColor: _background,
    appBarTheme: const AppBarTheme(
      backgroundColor: _primary,
      foregroundColor: _onPrimary,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _secondary,
      foregroundColor: _onSecondary,
    ),
    cardTheme: CardThemeData(
      color: _surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primary.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: _onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _primary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _surface,
      selectedItemColor: _primary,
      unselectedItemColor: Color(0xFF9E9E9E),
    ),
  );
}
