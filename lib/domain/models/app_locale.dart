import 'package:flutter/material.dart';

/// Product locales supported by the app.
enum AppLocale { pt, en, es }

/// Maps [AppLocale] to the concrete [Locale] and language code Flutter uses.
extension AppLocaleX on AppLocale {
  String get languageCode => switch (this) {
    AppLocale.pt => 'pt',
    AppLocale.en => 'en',
    AppLocale.es => 'es',
  };

  Locale get locale => Locale(languageCode);
}

/// Resolves a persisted language code back to [AppLocale].
///
/// Falls back to [AppLocale.pt] for `null` or an unsupported code, matching
/// the app's default locale.
AppLocale appLocaleFromLanguageCode(String? languageCode) {
  return AppLocale.values.firstWhere(
    (locale) => locale.languageCode == languageCode,
    orElse: () => AppLocale.pt,
  );
}
