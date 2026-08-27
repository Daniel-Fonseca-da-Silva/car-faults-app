abstract final class AppAssets {
  static const logo = 'assets/images/logo/logo.png';
  static const garage =
      'assets/images/garage/1951-volkswagen-beetle-garage-scene.webp';
  static const privacyHero = 'assets/images/privacy-term/Fiat-500-docs.webp';
  static const aboutFounderPhoto =
      'assets/images/about/daniel-fonseca-da-silva.jpg';

  static const _supportedLegalLanguages = {'pt', 'en', 'es'};
  static const _defaultLegalLanguage = 'pt';

  /// Path to the bundled privacy/terms JSON for [languageCode].
  ///
  /// Falls back to Portuguese when the language is not one of the
  /// product locales (pt, en, es).
  static String legalDocument(String languageCode) {
    final code = _supportedLegalLanguages.contains(languageCode)
        ? languageCode
        : _defaultLegalLanguage;
    return 'assets/legal/privacy_$code.json';
  }
}
