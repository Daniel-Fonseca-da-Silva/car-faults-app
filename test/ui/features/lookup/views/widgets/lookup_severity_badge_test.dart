import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/theme/app_colors.dart';
import 'package:car_faults_app/ui/features/lookup/views/widgets/lookup_severity_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(IssueSeverity severity) {
  return MaterialApp(
    locale: const Locale('pt'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: LookupSeverityBadge(severity: severity)),
  );
}

void main() {
  testWidgets('shows the localized label for each severity', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(IssueSeverity.critical));
    expect(find.text('Crítica'), findsOneWidget);

    await tester.pumpWidget(_app(IssueSeverity.high));
    expect(find.text('Alta'), findsOneWidget);

    await tester.pumpWidget(_app(IssueSeverity.medium));
    expect(find.text('Média'), findsOneWidget);

    await tester.pumpWidget(_app(IssueSeverity.low));
    expect(find.text('Baixa'), findsOneWidget);
  });

  testWidgets('critical severity uses the AppColors.critical token', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(IssueSeverity.critical));

    final text = tester.widget<Text>(find.text('Crítica'));
    expect(text.style?.color, AppColors.critical);
  });
}
