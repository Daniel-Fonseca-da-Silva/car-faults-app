import 'package:car_faults_app/data/repositories/platform_repository.dart';
import 'package:car_faults_app/domain/models/app_locale.dart';
import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:car_faults_app/domain/models/top_fault.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/features/home/view_models/home_top_faults_view_model.dart';
import 'package:car_faults_app/ui/features/home/views/widgets/home_top_faults_section.dart';
import 'package:car_faults_app/ui/features/home/views/widgets/top_fault_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePlatformRepository extends PlatformRepository {
  _FakePlatformRepository(this.faults);

  final List<TopFault> faults;

  @override
  Future<List<TopFault>> getTopFaults({
    required AppLocale locale,
    int limit = 6,
  }) async {
    return faults;
  }
}

const _sampleFaults = [
  TopFault(
    id: 'injection',
    title: 'Falha no sistema de injeção eletrónica',
    severity: IssueSeverity.high,
    reportCount: 1842,
    vehicleBrand: 'Volkswagen',
    vehicleModel: 'Gol',
    vehicleYearFrom: 2015,
  ),
  TopFault(
    id: 'corrosion',
    title: 'Corrosão precoce na carroçaria',
    severity: IssueSeverity.medium,
    reportCount: 2310,
    vehicleBrand: 'Fiat',
    vehicleModel: 'Uno',
    vehicleYearFrom: 2012,
  ),
];

void main() {
  // The section is taller than the test viewport, so it is pumped inside a
  // scrollable, just like HomeView does.
  Future<void> pumpSection(WidgetTester tester) async {
    final viewModel = HomeTopFaultsViewModel(
      repository: _FakePlatformRepository(_sampleFaults),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: HomeTopFaultsSection(viewModel: viewModel),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the header title and a card per mocked entry', (
    WidgetTester tester,
  ) async {
    await pumpSection(tester);

    expect(find.text('AVARIAS MAIS REPORTADAS'), findsOneWidget);
    expect(find.byType(TopFaultCard), findsNWidgets(_sampleFaults.length));
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
