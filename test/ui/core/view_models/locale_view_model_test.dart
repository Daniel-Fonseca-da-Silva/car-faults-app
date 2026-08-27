import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/domain/models/app_locale.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLocaleRepository extends LocaleRepository {
  _FakeLocaleRepository() : super(service: LocalePreferencesService());

  AppLocale? savedLocale;
  var callCount = 0;

  @override
  Future<void> save(AppLocale locale) async {
    callCount++;
    savedLocale = locale;
  }
}

void main() {
  test('defaults to the given initialLocale', () {
    final viewModel = LocaleViewModel(
      repository: _FakeLocaleRepository(),
      initialLocale: AppLocale.es,
    );

    expect(viewModel.locale, AppLocale.es);
  });

  test('setLocale updates the locale, persists it and notifies', () async {
    final repository = _FakeLocaleRepository();
    final viewModel = LocaleViewModel(repository: repository);
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    await viewModel.setLocale(AppLocale.en);

    expect(viewModel.locale, AppLocale.en);
    expect(repository.savedLocale, AppLocale.en);
    expect(notifications, 1);
  });

  test('setLocale is a no-op when the locale is already active', () async {
    final repository = _FakeLocaleRepository();
    final viewModel = LocaleViewModel(repository: repository);
    var notified = false;
    viewModel.addListener(() => notified = true);

    await viewModel.setLocale(AppLocale.pt);

    expect(notified, isFalse);
    expect(repository.callCount, 0);
  });
}
