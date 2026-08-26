import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/features/home/home_top_faults_display.dart';
import 'package:car_faults_app/ui/features/home/views/widgets/home_top_faults_section.dart';
import 'package:car_faults_app/ui/features/home/views/widgets/top_fault_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The section is taller than the test viewport, so it is pumped inside a
  // scrollable, just like HomeView does.
  Future<void> pumpSection(WidgetTester tester) {
    return tester.pumpWidget(
      const MaterialApp(
        locale: Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(child: HomeTopFaultsSection()),
        ),
      ),
    );
  }

  testWidgets('shows the header title and a card per mocked entry', (
    WidgetTester tester,
  ) async {
    await pumpSection(tester);

    expect(find.text('AVARIAS MAIS REPORTADAS'), findsOneWidget);
    expect(
      find.byType(TopFaultCard),
      findsNWidgets(HomeTopFaultsDisplay.entries.length),
    );
    expect(find.text('Volkswagen Gol'), findsOneWidget);
    expect(find.text('Falha no sistema de injeção eletrónica'), findsOneWidget);
  });

  testWidgets('exposes a semantic label for the card list', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semanticsHandle = tester.ensureSemantics();

    await pumpSection(tester);

    expect(
      find.bySemanticsLabel(RegExp('^Avarias mais reportadas')),
      findsOneWidget,
    );

    semanticsHandle.dispose();
  });
}
