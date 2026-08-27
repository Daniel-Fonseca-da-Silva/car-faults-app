import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/features/lookup/views/widgets/lookup_issues_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app() {
  return const MaterialApp(
    locale: Locale('pt'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: LookupIssuesSummary()),
  );
}

void main() {
  testWidgets(
    'shows the total, critical and high severity counts derived from the '
    'known issues',
    (WidgetTester tester) async {
      await tester.pumpWidget(_app());

      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
      expect(
        find.text(
          'Encontramos 3 defeitos conhecidos para este veículo, incluindo '
          '1 crítico(s) e 1 de alta severidade.',
        ),
        findsOneWidget,
      );
    },
  );
}
