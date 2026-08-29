import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/features/profile/profile_demo_display.dart';
import 'package:car_faults_app/ui/features/profile/views/widgets/profile_stat_card.dart';
import 'package:car_faults_app/ui/features/profile/views/widgets/profile_stats_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app() {
  return MaterialApp(
    locale: const Locale('pt'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: ProfileStatsGrid(snapshot: ProfileDemoDisplay.snapshot),
    ),
  );
}

void main() {
  testWidgets('shows the four stat values and labels', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(find.text('47'), findsOneWidget);
    expect(find.text('Buscas realizadas'), findsOneWidget);
    expect(find.text('128'), findsOneWidget);
    expect(find.text('Defeitos consultados'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('Os meus veículos'), findsOneWidget);
    expect(find.text('23'), findsOneWidget);
    expect(find.text('Votos dados'), findsOneWidget);
    expect(find.byType(ProfileStatCard), findsNWidgets(4));
  });

  testWidgets('lays out as 2x2 on phone-width screens', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());

    expect(find.byType(Row), findsNWidgets(2));
  });

  testWidgets('lays out as a single row on tablet-width screens', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(900, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());

    expect(find.byType(Row), findsOneWidget);
  });
}
