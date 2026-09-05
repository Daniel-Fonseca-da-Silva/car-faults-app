import 'package:car_faults_app/data/repositories/platform_repository.dart';
import 'package:car_faults_app/domain/models/platform_stats.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/widgets/stat_item.dart';
import 'package:car_faults_app/ui/features/home/view_models/home_stats_view_model.dart';
import 'package:car_faults_app/ui/features/home/views/widgets/home_stats_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePlatformRepository extends PlatformRepository {
  _FakePlatformRepository(this.stats);

  final PlatformStats stats;

  @override
  Future<PlatformStats> getStats() async => stats;
}

void main() {
  const sampleStats = PlatformStats(
    faultsCount: 1200000,
    vehiclesCount: 8400,
    reportsCount: 34000,
  );

  Future<void> pumpStats(WidgetTester tester) async {
    final viewModel = HomeStatsViewModel(
      repository: _FakePlatformRepository(sampleStats),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: HomeStatsSection(viewModel: viewModel)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the three mocked values with their labels', (
    WidgetTester tester,
  ) async {
    await pumpStats(tester);

    expect(find.byType(StatItem), findsNWidgets(3));

    expect(find.text('1.200.000'), findsOneWidget);
    expect(find.text('Defeitos registados'), findsOneWidget);
    expect(find.text('8.400'), findsOneWidget);
    expect(find.text('Modelos catalogados'), findsOneWidget);
    expect(find.text('34.000'), findsOneWidget);
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
