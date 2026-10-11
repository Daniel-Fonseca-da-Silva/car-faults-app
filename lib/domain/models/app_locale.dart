import 'package:flutter/material.dart';

/// Product locales supported by the app.
enum AppLocale { pt, ptBr, en, es, fr }

/// Maps [AppLocale] to the concrete [Locale] and language code Flutter uses.
extension AppLocaleX on AppLocale {
  String get languageCode => switch (this) {
    AppLocale.pt || AppLocale.ptBr => 'pt',
    AppLocale.en => 'en',
    AppLocale.es => 'es',
    AppLocale.fr => 'fr',
  };

  /// Region subtag for locales that differ by country (e.g. `BR`), otherwise
  /// `null`.
  String? get countryCode => switch (this) {
    AppLocale.ptBr => 'BR',
    _ => null,
  };

  /// Stable identifier persisted in preferences and used to pick bundled
  /// assets: the language code, plus `_<country>` for regional variants
  /// (e.g. `pt`, `pt_BR`).
  String get code =>
      countryCode == null ? languageCode : '${languageCode}_$countryCode';

  Locale get locale => Locale(languageCode, countryCode);
}

/// Resolves a persisted [AppLocaleX.code] back to [AppLocale].
///
/// Falls back to [AppLocale.en] for `null` or an unsupported code, matching
/// the app's default locale.
AppLocale appLocaleFromLanguageCode(String? languageCode) {
  return AppLocale.values.firstWhere(
    (locale) => locale.code == languageCode,
    orElse: () => AppLocale.en,
  );
}

/// Resolves the active Flutter [Locale] to [AppLocale], matching the region
/// first (so `pt_BR` maps to [AppLocale.ptBr]) and then the language alone.
AppLocale appLocaleFromLocale(Locale locale) {
  return AppLocale.values.firstWhere(
    (appLocale) =>
        appLocale.languageCode == locale.languageCode &&
        appLocale.countryCode == locale.countryCode,
    orElse: () => appLocaleFromLanguageCode(locale.languageCode),
  );
}
