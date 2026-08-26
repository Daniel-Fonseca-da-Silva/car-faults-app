import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/widgets/stat_item.dart';
import 'package:car_faults_app/ui/features/home/views/widgets/home_stats_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpStats(WidgetTester tester) {
    return tester.pumpWidget(
      const MaterialApp(
        locale: Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: HomeStatsSection()),
      ),
    );
  }

  testWidgets('shows the three mocked values with their labels', (
    WidgetTester tester,
  ) async {
    await pumpStats(tester);

    expect(find.byType(StatItem), findsNWidgets(3));

    expect(find.text('1.2M+'), findsOneWidget);
    expect(find.text('Defeitos registados'), findsOneWidget);
    expect(find.text('8.400+'), findsOneWidget);
    expect(find.text('Modelos catalogados'), findsOneWidget);
    expect(find.text('34.000+'), findsOneWidget);
    expect(find.text('Recalls documentados'), findsOneWidget);
  });

  testWidgets('exposes a semantic label for the stats group', (
    WidgetTester tester,
  ) async {
    // The semantics tree is only built while a handle is alive.
    final SemanticsHandle semanticsHandle = tester.ensureSemantics();

    await pumpStats(tester);

    // Stat items are merged into the group node, so the group label only
    // prefixes the announced text.
    expect(
      find.bySemanticsLabel(RegExp('^Estatísticas da plataforma')),
      findsOneWidget,
    );

    semanticsHandle.dispose();
  });
}
