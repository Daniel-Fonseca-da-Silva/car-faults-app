import 'package:car_faults_app/data/mappers/locale_mapper.dart';
import 'package:car_faults_app/domain/models/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps pt to pt-PT', () {
    expect(apiLanguageFor(AppLocale.pt), 'pt-PT');
  });

  test('maps en to en-GB', () {
    expect(apiLanguageFor(AppLocale.en), 'en-GB');
  });

  test('maps es to es-ES', () {
    expect(apiLanguageFor(AppLocale.es), 'es-ES');
  });
}
