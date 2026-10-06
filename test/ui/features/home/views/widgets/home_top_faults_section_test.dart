import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/repositories/lookup_repository.dart';
import 'package:car_faults_app/data/repositories/platform_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/domain/models/app_locale.dart';
import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:car_faults_app/domain/models/top_fault.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/features/home/home_search_options.dart';
import 'package:car_faults_app/ui/features/home/view_models/home_top_faults_view_model.dart';
import 'package:car_faults_app/ui/features/home/views/widgets/home_top_faults_section.dart';
import 'package:car_faults_app/ui/features/home/views/widgets/top_fault_card.dart';
import 'package:car_faults_app/ui/features/lookup/lookup_demo_display.dart';
import 'package:car_faults_app/ui/features/lookup/views/lookup_results_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

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

class _FakeLookupRepository extends LookupRepository {
  _FakeLookupRepository(this.result);

  final LookupSearchResult result;

  @override
  Future<LookupSearchResult> search({
    required String brand,
    required String model,
    required int year,
    required String engine,
    required FuelOption fuel,
    int? doors,
    required AppLocale locale,
  }) async => result;
}

const _openableFault = TopFault(
  id: 'f1',
  title: 'Oil leak',
  severity: IssueSeverity.medium,
  reportCount: 10,
  contentLocale: 'pt-PT',
  vehicleBrand: 'Audi',
  vehicleModel: 'A4',
  vehicleYearFrom: 2018,
  vehicleEngine: '2.0 TFSI',
);

const _sampleFaults = [
  TopFault(
    id: 'injection',
    title: 'Falha no sistema de injeção eletrónica',
    severity: IssueSeverity.high,
    reportCount: 1842,
    contentLocale: 'pt-PT',
    vehicleBrand: 'Volkswagen',
    vehicleModel: 'Gol',
    vehicleYearFrom: 2015,
  ),
  TopFault(
    id: 'corrosion',
    title: 'Corrosão precoce na carroçaria',
    severity: IssueSeverity.medium,
    reportCount: 2310,
    contentLocale: 'pt-PT',
    vehicleBrand: 'Fiat',
    vehicleModel: 'Uno',
    vehicleYearFrom: 2012,
  ),
];

void main() {
  // The section is taller than the test viewport, so it is pumped inside a
  // scrollable, just like HomeView does.
  Future<void> pumpSection(
    WidgetTester tester, {
    List<TopFault> faults = _sampleFaults,
    LookupRepository? lookupRepository,
  }) async {
    final viewModel = HomeTopFaultsViewModel(
      repository: _FakePlatformRepository(faults),
      lookupRepository: lookupRepository,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => LocaleViewModel(
              repository: LocaleRepository(service: LocalePreferencesService()),
            ),
          ),
          ChangeNotifierProvider(create: (_) => AuthSessionViewModel()),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          locale: const Locale('pt'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: HomeTopFaultsSection(viewModel: viewModel),
            ),
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

  testWidgets('shows the empty state and no cards when there are no faults', (
    WidgetTester tester,
  ) async {
    await pumpSection(tester, faults: const []);

    expect(find.byType(TopFaultCard), findsNothing);
    expect(
      find.text(
        'Ainda não há avarias reportadas. Seja o primeiro a reportar uma.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('tapping a fault opens its lookup results', (
    WidgetTester tester,
  ) async {
    await pumpSection(
      tester,
      faults: const [_openableFault],
      lookupRepository: _FakeLookupRepository(
        LookupSearchSuccess(
          vehicle: LookupDemoDisplay.vehicle,
          issues: LookupDemoDisplay.issues,
        ),
      ),
    );

    await tester.tap(find.byType(TopFaultCard));
    await tester.pumpAndSettle();

    expect(find.byType(LookupResultsView), findsOneWidget);
  });

  testWidgets('a fault with no engine on record is not tappable', (
    WidgetTester tester,
  ) async {
    await pumpSection(tester);

    expect(
      find.descendant(
        of: find.byType(TopFaultCard),
        matching: find.byType(InkWell),
      ),
      findsNothing,
    );
  });
}
