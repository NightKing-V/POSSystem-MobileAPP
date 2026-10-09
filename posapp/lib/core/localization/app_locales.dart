import 'package:flutter/material.dart';

class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String flagEmoji;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flagEmoji,
  });

  Locale get locale => Locale(code);
}

class AppLocales {
  AppLocales._();

  static const defaultLocale = Locale('en');

  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flagEmoji: '🇺🇸',
    ),
    AppLanguage(
      code: 'si',
      name: 'Sinhala',
      nativeName: 'සිංහල',
      flagEmoji: '🇱🇰',
    ),
    AppLanguage(
      code: 'ta',
      name: 'Tamil',
      nativeName: 'தமிழ்',
      flagEmoji: '🇱🇰',
    ),
  ];

  static List<Locale> get supportedLocales =>
      supportedLanguages.map((l) => l.locale).toList();

  static AppLanguage getLanguage(String code) {
    return supportedLanguages.firstWhere(
      (l) => l.code == code,
      orElse: () => supportedLanguages.first,
    );
  }
}
