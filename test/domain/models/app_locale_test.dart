import 'package:car_faults_app/domain/models/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('languageCode and locale match for every AppLocale', () {
    expect(AppLocale.pt.languageCode, 'pt');
    expect(AppLocale.pt.locale, const Locale('pt'));
    expect(AppLocale.en.languageCode, 'en');
    expect(AppLocale.en.locale, const Locale('en'));
    expect(AppLocale.es.languageCode, 'es');
    expect(AppLocale.es.locale, const Locale('es'));
  });

  test('appLocaleFromLanguageCode resolves a known code', () {
    expect(appLocaleFromLanguageCode('en'), AppLocale.en);
    expect(appLocaleFromLanguageCode('es'), AppLocale.es);
  });

  test('appLocaleFromLanguageCode falls back to pt for null or unknown', () {
    expect(appLocaleFromLanguageCode(null), AppLocale.pt);
    expect(appLocaleFromLanguageCode('fr'), AppLocale.pt);
  });
}
