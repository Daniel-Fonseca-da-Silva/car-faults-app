import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/domain/models/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLocalePreferencesService extends LocalePreferencesService {
  _FakeLocalePreferencesService({this.storedCode});

  String? storedCode;

  @override
  Future<String?> readLanguageCode() async => storedCode;

  @override
  Future<void> writeLanguageCode(String languageCode) async {
    storedCode = languageCode;
  }
}

void main() {
  test('load resolves the stored language code', () async {
    final service = _FakeLocalePreferencesService(storedCode: 'en');
    final repository = LocaleRepository(service: service);

    expect(await repository.load(), AppLocale.en);
  });

  test('load falls back to pt when nothing is stored', () async {
    final service = _FakeLocalePreferencesService();
    final repository = LocaleRepository(service: service);

    expect(await repository.load(), AppLocale.pt);
  });

  test('save writes the locale language code via the service', () async {
    final service = _FakeLocalePreferencesService();
    final repository = LocaleRepository(service: service);

    await repository.save(AppLocale.es);

    expect(service.storedCode, 'es');
  });
}
