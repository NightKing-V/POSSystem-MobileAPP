import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_locales.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};
  Map<String, String> _fallbackStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Loads translation map from JSON
  Future<bool> load() async {
    // 1. Load fallback (English)
    try {
      final fallbackJson =
          await rootBundle.loadString('assets/translations/en.json');
      final Map<String, dynamic> fallbackMap = json.decode(fallbackJson);
      _fallbackStrings = _flattenMap(fallbackMap);
    } catch (_) {}

    // 2. Load current locale if not English
    if (locale.languageCode != 'en') {
      try {
        final jsonString = await rootBundle
            .loadString('assets/translations/${locale.languageCode}.json');
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        _localizedStrings = _flattenMap(jsonMap);
      } catch (_) {
        _localizedStrings = _fallbackStrings;
      }
    } else {
      _localizedStrings = _fallbackStrings;
    }

    return true;
  }

  /// Flattens nested JSON object into dot-notated key-value map
  /// e.g. { "orgs": { "title": "Store" } } => { "orgs.title": "Store" }
  Map<String, String> _flattenMap(Map<String, dynamic> jsonMap, [String prefix = '']) {
    final Map<String, String> result = {};

    jsonMap.forEach((key, value) {
      final currentKey = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map<String, dynamic>) {
        result.addAll(_flattenMap(value, currentKey));
      } else if (value != null) {
        result[currentKey] = value.toString();
      }
    });

    return result;
  }

  /// Translates a key with optional dynamic argument replacement
  String translate(String key, {Map<String, dynamic>? args}) {
    String text = _localizedStrings[key] ?? _fallbackStrings[key] ?? key;

    if (args != null && args.isNotEmpty) {
      args.forEach((k, v) {
        text = text.replaceAll('{$k}', v.toString());
      });
    }

    return text;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocales.supportedLocales
        .any((l) => l.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Handy extension on [BuildContext] for easy translations:
/// `context.tr('orgs.select_business')`
extension LocalizationExtension on BuildContext {
  String tr(String key, {Map<String, dynamic>? args}) {
    final loc = AppLocalizations.of(this);
    if (loc != null) {
      return loc.translate(key, args: args);
    }
    return key;
  }
}
