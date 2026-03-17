import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubar/core/theme/app_theme.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.nubar);

  void setTheme(AppThemeMode mode) {
    state = mode;
  }

  void setThemeFromString(String value) {
    state = AppTheme.fromString(value);
  }
}
