import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/widgets/labeled_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  testWidgets('shows the uppercase label and the child', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(const LabeledField(label: 'marca', child: Text('input'))),
    );

    expect(find.text('MARCA'), findsOneWidget);
    expect(find.text('input'), findsOneWidget);
  });

  testWidgets('hides the optional badge by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(const LabeledField(label: 'MARCA', child: Text('input'))),
    );

    expect(find.text('opcional'), findsNothing);
  });

  testWidgets('shows the optional badge when asked', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const LabeledField(
          label: 'PORTAS',
          showOptionalBadge: true,
          child: Text('input'),
        ),
      ),
    );

    expect(find.text('opcional'), findsOneWidget);
  });
}
