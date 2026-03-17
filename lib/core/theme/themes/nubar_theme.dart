import 'package:flutter/material.dart';

/// Kürt ulusal renkleri: kırmızı, yeşil, sarı ve açık/koyu tonları.
/// "Benim sesim" — bayrak renkleriyle uyumlu varsayılan tema.
class NubarTheme {
  NubarTheme._();

  // ——— Yeşil (bayrak alt şeridi) ———
  static const Color _greenDark = Color(0xFF006747);
  static const Color _green = Color(0xFF007A3D);
  static const Color _greenLight = Color(0xFF2E7D5E);
  static const Color _greenPale = Color(0xFFE8F5E9);

  // ——— Kırmızı (bayrak üst şeridi) ———
  static const Color _redDark = Color(0xFF8B1538);
  static const Color _red = Color(0xFFC8102E);
  static const Color _redLight = Color(0xFFE53935);
  static const Color _redPale = Color(0xFFFFEBEE);

  // ——— Sarı (güneş / vurgu) ———
  static const Color _yellowDark = Color(0xFFB8860B);
  static const Color _yellow = Color(0xFFFCD116);
  static const Color _yellowLight = Color(0xFFFFE082);
  static const Color _yellowPale = Color(0xFFFFFDE7);

  // Birincil: yeşil, ikincil: kırmızı, vurgu: sarı
  static const Color _primary = _green;
  static const Color _primaryContainer = _greenPale;
  static const Color _secondary = _red;
  static const Color _secondaryContainer = _redPale;
  static const Color _tertiary = _yellow;
  static const Color _tertiaryContainer = _yellowPale;

  static const Color _background = Color(0xFFFAFAF8);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _surfaceVariant = Color(0xFFF5F5F0);
  static const Color _onPrimary = Color(0xFFFFFFFF);
  static const Color _onSecondary = Color(0xFFFFFFFF);
  static const Color _onTertiary = Color(0xFF1A1A1A);
  static const Color _onBackground = Color(0xFF1A1A1A);
  static const Color _onSurface = Color(0xFF1A1A1A);
  static const Color _onSurfaceVariant = Color(0xFF5C5C5C);
  static const Color _error = Color(0xFFB00020);
  static const Color _outline = Color(0xFF006747);

  static ThemeData get themeData => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: _primary,
          onPrimary: _onPrimary,
          primaryContainer: _primaryContainer,
          onPrimaryContainer: _greenDark,
          secondary: _secondary,
          onSecondary: _onSecondary,
          secondaryContainer: _secondaryContainer,
          onSecondaryContainer: _redDark,
          tertiary: _tertiary,
          onTertiary: _onTertiary,
          tertiaryContainer: _tertiaryContainer,
          onTertiaryContainer: _yellowDark,
          error: _error,
          onError: Color(0xFFFFFFFF),
          surface: _surface,
          onSurface: _onSurface,
          surfaceContainerHighest: _surfaceVariant,
          onSurfaceVariant: _onSurfaceVariant,
          outline: _outline,
        ),
        scaffoldBackgroundColor: _background,
        appBarTheme: const AppBarTheme(
          backgroundColor: _primary,
          foregroundColor: _onPrimary,
          elevation: 0,
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _secondary,
          foregroundColor: _onSecondary,
        ),
        cardTheme: CardThemeData(
          color: _surface,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _primary.withValues(alpha: 0.4)),
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
          backgroundColor: _surface,
          selectedItemColor: _primary,
          unselectedItemColor: _onSurfaceVariant,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _surface,
          indicatorColor: _primaryContainer,
          elevation: 0,
          height: 80,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: _primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              );
            }
            return const TextStyle(
              color: _onSurfaceVariant,
              fontSize: 12,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: _primary, size: 26);
            }
            return const IconThemeData(color: _onSurfaceVariant, size: 24);
          }),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: _primaryContainer,
          selectedColor: _primary,
          labelStyle: const TextStyle(color: _greenDark),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
}
