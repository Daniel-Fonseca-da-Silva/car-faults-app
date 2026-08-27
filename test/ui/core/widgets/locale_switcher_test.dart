import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/domain/models/app_locale.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/core/widgets/locale_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeLocaleRepository extends LocaleRepository {
  _FakeLocaleRepository() : super(service: LocalePreferencesService());

  AppLocale? savedLocale;

  @override
  Future<void> save(AppLocale locale) async {
    savedLocale = locale;
  }
}

Widget _app(LocaleViewModel viewModel) {
  return ChangeNotifierProvider.value(
    value: viewModel,
    child: MaterialApp(
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: LocaleSwitcher()),
    ),
  );
}

void main() {
  testWidgets('trigger shows the active locale code, not the full label', (
    WidgetTester tester,
  ) async {
    final viewModel = LocaleViewModel(repository: _FakeLocaleRepository());
    await tester.pumpWidget(_app(viewModel));

    expect(find.text('PT'), findsOneWidget);
    expect(find.text('Português (PT)'), findsNothing);
  });

  testWidgets('opening the menu lists all locales and checks the active one', (
    WidgetTester tester,
  ) async {
    final viewModel = LocaleViewModel(repository: _FakeLocaleRepository());
    await tester.pumpWidget(_app(viewModel));

    await tester.tap(find.byType(PopupMenuButton<AppLocale>));
    await tester.pumpAndSettle();

    expect(find.text('English (UK)'), findsOneWidget);
    expect(find.text('Español (ES)'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('selecting a locale calls setLocale and updates the trigger', (
    WidgetTester tester,
  ) async {
    final repository = _FakeLocaleRepository();
    final viewModel = LocaleViewModel(repository: repository);
    await tester.pumpWidget(_app(viewModel));

    await tester.tap(find.byType(PopupMenuButton<AppLocale>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English (UK)'));
    await tester.pumpAndSettle();

    expect(viewModel.locale, AppLocale.en);
    expect(repository.savedLocale, AppLocale.en);
    expect(find.text('EN'), findsOneWidget);
  });
}
