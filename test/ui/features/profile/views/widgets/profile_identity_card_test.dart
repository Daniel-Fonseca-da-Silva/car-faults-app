import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/features/profile/profile_demo_display.dart';
import 'package:car_faults_app/ui/features/profile/views/widgets/profile_identity_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app() {
  return MaterialApp(
    locale: const Locale('pt'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: ProfileIdentityCard(snapshot: ProfileDemoDisplay.snapshot),
    ),
  );
}

void main() {
  testWidgets('shows the name, email and member since pill', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(find.text('Ana Silva'), findsOneWidget);
    expect(find.text('ana@example.com'), findsOneWidget);
    expect(find.text('Membro desde julho de 2026'), findsOneWidget);
  });

  testWidgets('shows the initials avatar when there is no photo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(find.text('AS'), findsOneWidget);
  });

  testWidgets('exposes the online status via semantics', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(find.bySemanticsLabel('Online'), findsOneWidget);
  });
}
