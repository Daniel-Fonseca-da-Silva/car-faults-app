import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('readLanguageCode returns null when nothing was saved', () async {
    final service = LocalePreferencesService();

    expect(await service.readLanguageCode(), isNull);
  });

  test('writeLanguageCode persists the value for readLanguageCode', () async {
    final service = LocalePreferencesService();

    await service.writeLanguageCode('es');

    expect(await service.readLanguageCode(), 'es');
  });
}
