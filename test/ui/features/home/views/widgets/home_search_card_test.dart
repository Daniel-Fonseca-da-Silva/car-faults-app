import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/widgets/app_autocomplete_field.dart';
import 'package:car_faults_app/ui/core/widgets/app_dropdown_field.dart';
import 'package:car_faults_app/ui/core/widgets/app_text_field.dart';
import 'package:car_faults_app/ui/core/widgets/labeled_field.dart';
import 'package:car_faults_app/ui/features/home/home_search_options.dart';
import 'package:car_faults_app/ui/features/home/views/widgets/home_search_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpCard(WidgetTester tester) {
    return tester.pumpWidget(
      const MaterialApp(
        locale: Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SingleChildScrollView(child: HomeSearchCard())),
      ),
    );
  }

  Future<void> openDropdown(WidgetTester tester, Finder dropdown) async {
    await tester.ensureVisible(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
  }

  String? brandText(WidgetTester tester) {
    final field = tester.widget<TextField>(
      find.descendant(
        of: find.byType(AppAutocompleteField),
        matching: find.byType(TextField),
      ),
    );
    return field.controller?.text;
  }

  /// The open menu is the innermost scrollable, and it builds its items lazily,
  /// so far-down options only exist after scrolling.
  Future<void> scrollMenuTo(WidgetTester tester, String option) {
    return tester.scrollUntilVisible(
      find.text(option),
      200,
      scrollable: find.byType(Scrollable).last,
    );
  }

  testWidgets('shows the header with search icon, title and active status', (
    WidgetTester tester,
  ) async {
    await pumpCard(tester);

    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.text('PESQUISAR VEÍCULO'), findsOneWidget);
    expect(find.text('Base de dados ativa'), findsOneWidget);
  });

  testWidgets('shows the six field labels', (WidgetTester tester) async {
    await pumpCard(tester);

    expect(find.byType(LabeledField), findsNWidgets(6));
    for (final label in const [
      'MARCA',
      'MODELO',
      'ANO',
      'MOTOR',
      'COMBUSTÍVEL',
      'PORTAS',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('marks only the doors field as optional', (
    WidgetTester tester,
  ) async {
    await pumpCard(tester);

    expect(find.text('opcional'), findsOneWidget);
  });

  testWidgets('header does not overflow on a narrow screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpCard(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('PESQUISAR VEÍCULO'), findsOneWidget);
    expect(find.text('Base de dados ativa'), findsOneWidget);
  });

  testWidgets('uses text fields for model and engine, dropdowns elsewhere', (
    WidgetTester tester,
  ) async {
    await pumpCard(tester);

    expect(find.byType(AppAutocompleteField), findsOneWidget);
    expect(find.byType(AppTextField), findsNWidgets(3));
    expect(find.byType(AppDropdownField<int>), findsNWidgets(2));
    expect(find.byType(AppDropdownField<FuelOption>), findsOneWidget);
    expect(find.text('Ex.: Gol, Civic, Corolla...'), findsOneWidget);
    expect(find.text('Número de portas'), findsOneWidget);
  });

  testWidgets('brand field suggests every make when focused', (
    WidgetTester tester,
  ) async {
    await pumpCard(tester);
    await tester.tap(find.byType(AppAutocompleteField));
    await tester.pumpAndSettle();

    expect(find.text(HomeSearchOptions.brands.first), findsOneWidget);
  });

  testWidgets('typing in the brand field filters the suggestions', (
    WidgetTester tester,
  ) async {
    await pumpCard(tester);
    await tester.enterText(find.byType(AppAutocompleteField), 'volks');
    await tester.pumpAndSettle();

    expect(find.text('Volkswagen'), findsOneWidget);
    expect(find.text('Renault'), findsNothing);
  });

  testWidgets('picking a suggestion fills the brand field', (
    WidgetTester tester,
  ) async {
    await pumpCard(tester);
    await tester.enterText(find.byType(AppAutocompleteField), 'volks');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Volkswagen'));
    await tester.pumpAndSettle();

    expect(brandText(tester), 'Volkswagen');
  });

  testWidgets('brand field keeps text that matches no make', (
    WidgetTester tester,
  ) async {
    await pumpCard(tester);
    await tester.enterText(find.byType(AppAutocompleteField), 'Marca Nova');
    await tester.pumpAndSettle();

    expect(brandText(tester), 'Marca Nova');
  });

  testWidgets('fuel dropdown lists the five translated options', (
    WidgetTester tester,
  ) async {
    await pumpCard(tester);
    await openDropdown(tester, find.byType(AppDropdownField<FuelOption>));

    for (final fuel in const [
      'Gasolina',
      'Gasóleo',
      'Elétrico',
      'GPL',
      'Híbrido',
    ]) {
      expect(find.text(fuel), findsOneWidget);
    }
  });

  testWidgets('selecting a fuel replaces the placeholder', (
    WidgetTester tester,
  ) async {
    await pumpCard(tester);
    await openDropdown(tester, find.byType(AppDropdownField<FuelOption>));

    await tester.tap(find.text('Gasóleo').last);
    await tester.pumpAndSettle();

    expect(find.text('Gasóleo'), findsOneWidget);
    expect(find.text('Tipo de combustível'), findsNothing);
  });

  testWidgets('doors dropdown lists two to five', (WidgetTester tester) async {
    await pumpCard(tester);
    await openDropdown(tester, find.byType(AppDropdownField<int>).last);

    for (final doors in const ['2', '3', '4', '5']) {
      expect(find.text(doors), findsOneWidget);
    }
  });

  testWidgets('year dropdown lists one entry per year, newest first', (
    WidgetTester tester,
  ) async {
    await pumpCard(tester);
    await openDropdown(tester, find.byType(AppDropdownField<int>).first);

    final years = HomeSearchOptions.years();
    final oldest = HomeSearchOptions.oldestYear;

    expect(years.first, DateTime.now().year + 1);
    expect(years.last, oldest);
    expect(years.length, years.first - oldest + 1);
    expect(find.text('${years.first}'), findsOneWidget);

    await scrollMenuTo(tester, '$oldest');

    expect(find.text('$oldest'), findsOneWidget);
  });
}
