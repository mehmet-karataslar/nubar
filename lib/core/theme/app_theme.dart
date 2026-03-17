import 'package:flutter/material.dart';
import 'package:nubar/core/theme/themes/nubar_theme.dart';
import 'package:nubar/core/theme/themes/dark_theme.dart';
import 'package:nubar/core/theme/themes/light_theme.dart';
import 'package:nubar/core/theme/themes/earth_theme.dart';
import 'package:nubar/core/theme/themes/ocean_theme.dart';
import 'package:nubar/core/theme/themes/amoled_theme.dart';

enum AppThemeMode {
  nubar,
  dark,
  light,
  earth,
  ocean,
  amoled,
}

class AppTheme {
  AppTheme._();

  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.nubar:
        return NubarTheme.themeData;
      case AppThemeMode.dark:
        return DarkTheme.themeData;
      case AppThemeMode.light:
        return LightTheme.themeData;
      case AppThemeMode.earth:
        return EarthTheme.themeData;
      case AppThemeMode.ocean:
        return OceanTheme.themeData;
      case AppThemeMode.amoled:
        return AmoledTheme.themeData;
    }
  }

  static AppThemeMode fromString(String value) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => AppThemeMode.nubar,
    );
  }
}
