import 'package:flutter/material.dart';
import 'app_locales.dart';

class LocaleController extends ChangeNotifier {
  static final LocaleController _instance = LocaleController._internal();
  factory LocaleController() => _instance;

  LocaleController._internal();

  Locale _locale = AppLocales.defaultLocale;

  Locale get locale => _locale;

  String get currentLanguageCode => _locale.languageCode;

  AppLanguage get currentLanguage => AppLocales.getLanguage(_locale.languageCode);

  void setLocale(Locale newLocale) {
    if (_locale.languageCode != newLocale.languageCode) {
      _locale = newLocale;
      notifyListeners();
    }
  }

  void changeLanguage(String languageCode) {
    final lang = AppLocales.getLanguage(languageCode);
    setLocale(lang.locale);
  }
}
