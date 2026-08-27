import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/core/widgets/app_header.dart';
import 'package:car_faults_app/ui/core/widgets/app_menu_button.dart';
import 'package:car_faults_app/ui/core/widgets/locale_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _app() {
  return ChangeNotifierProvider(
    create: (_) => LocaleViewModel(
      repository: LocaleRepository(service: LocalePreferencesService()),
    ),
    child: MaterialApp(
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: AppHeader()),
    ),
  );
}

void main() {
  testWidgets('does not overflow on a narrow screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());

    expect(tester.takeException(), isNull);
    expect(find.byType(LocaleSwitcher), findsOneWidget);
    expect(find.byType(AppMenuButton), findsOneWidget);
  });

  testWidgets('keeps the locale switcher and menu visible at a wider width', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(tester.takeException(), isNull);
    expect(find.byType(LocaleSwitcher), findsOneWidget);
    expect(find.byType(AppMenuButton), findsOneWidget);
  });
}
