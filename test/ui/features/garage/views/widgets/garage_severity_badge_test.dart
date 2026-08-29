import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/features/garage/views/widgets/garage_severity_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(IssueSeverity severity) {
  return MaterialApp(
    locale: const Locale('pt'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: GarageSeverityBadge(severity: severity)),
  );
}

void main() {
  testWidgets('high severity shows the "Alta" label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(IssueSeverity.high));

    expect(find.text('Alta'), findsOneWidget);
  });

  testWidgets('medium severity shows the "Média" label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(IssueSeverity.medium));

    expect(find.text('Média'), findsOneWidget);
  });
}
