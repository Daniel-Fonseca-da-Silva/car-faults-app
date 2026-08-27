import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/features/lookup/views/widgets/lookup_tech_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app() {
  return const MaterialApp(
    locale: Locale('pt'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: LookupTechSpecs()),
  );
}

void main() {
  testWidgets('shows the five spec labels and values', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(find.text('ANOS'), findsOneWidget);
    expect(find.text('MOTOR'), findsOneWidget);
    expect(find.text('COMBUSTÍVEL'), findsOneWidget);
    expect(find.text('PORTAS'), findsOneWidget);
    expect(find.text('POTÊNCIA'), findsOneWidget);

    expect(find.text('1994 - 1999'), findsOneWidget);
    expect(find.text('1.6'), findsOneWidget);
    expect(find.text('Gasolina'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('101 hp'), findsOneWidget);
  });
}
