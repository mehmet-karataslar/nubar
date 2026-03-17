import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Fallback delegate that provides [MaterialLocalizations] and
/// [CupertinoLocalizations] for app locales (ku, ckb, ar, tr) that Flutter's
/// global delegates do not support. Uses English so Material/Cupertino widgets
/// (e.g. TextField, date picker) have labels without throwing.

const List<Locale> _flutterUnsupportedAppLocales = [
  Locale('ku'),
  Locale('ckb'),
  Locale('ar'),
  Locale('tr'),
];

bool _isUnsupported(Locale locale) {
  return _flutterUnsupportedAppLocales
      .any((l) => l.languageCode == locale.languageCode);
}

class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => _isUnsupported(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => _isUnsupported(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}

class FallbackWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const FallbackWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => _isUnsupported(locale);

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(FallbackWidgetsLocalizationsDelegate old) => false;
}
