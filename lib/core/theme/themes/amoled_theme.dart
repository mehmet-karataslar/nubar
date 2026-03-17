import 'package:flutter/material.dart';

class AmoledTheme {
  AmoledTheme._();

  static const Color _primary = Color(0xFF40916C);
  static const Color _secondary = Color(0xFFE9C46A);
  static const Color _background = Color(0xFF000000);
  static const Color _surface = Color(0xFF0A0A0A);
  static const Color _onPrimary = Color(0xFFFFFFFF);
  static const Color _onSecondary = Color(0xFF1A1A1A);
  static const Color _onBackground = Color(0xFFE6E6E6);
  static const Color _onSurface = Color(0xFFE6E6E6);
  static const Color _error = Color(0xFFCF6679);

  static ThemeData get themeData => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: _primary,
          onPrimary: _onPrimary,
          secondary: _secondary,
          onSecondary: _onSecondary,
          error: _error,
          onError: Color(0xFF1A1A1A),
          surface: _surface,
          onSurface: _onSurface,
        ),
        scaffoldBackgroundColor: _background,
        appBarTheme: const AppBarTheme(
          backgroundColor: _background,
          foregroundColor: _onSurface,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _secondary,
          foregroundColor: _onSecondary,
        ),
        cardTheme: CardThemeData(
          color: _surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _primary.withValues(alpha: 0.2)),
          ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: _primary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: _background,
          selectedItemColor: _primary,
          unselectedItemColor: Color(0xFF6E7681),
        ),
      );
}
