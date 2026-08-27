import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/features/lookup/views/widgets/lookup_back_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(VoidCallback onPressed) {
  return MaterialApp(
    locale: const Locale('pt'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: LookupBackLink(onPressed: onPressed)),
  );
}

void main() {
  testWidgets('shows the "Nova busca" label and an arrow icon', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(() {}));

    expect(find.text('Nova busca'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
    var tapped = false;

    await tester.pumpWidget(_app(() => tapped = true));
    await tester.tap(find.byType(LookupBackLink));

    expect(tapped, isTrue);
  });
}
