import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/repositories/lookup_repository.dart';
import 'package:car_faults_app/data/repositories/platform_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/domain/models/app_locale.dart';
import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:car_faults_app/domain/models/top_fault.dart';
import 'package:car_faults_app/domain/models/top_faults_page.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/features/defects/view_models/defects_view_model.dart';
import 'package:car_faults_app/ui/features/defects/views/defects_view.dart';
import 'package:car_faults_app/ui/features/home/home_search_options.dart';
import 'package:car_faults_app/ui/features/home/views/widgets/top_fault_card.dart';
import 'package:car_faults_app/ui/features/lookup/lookup_demo_display.dart';
import 'package:car_faults_app/ui/features/lookup/views/lookup_results_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakePlatformRepository extends PlatformRepository {
  _FakePlatformRepository({this.page, this.error});

  TopFaultsPage? page;
  Object? error;

  @override
  Future<TopFaultsPage> getTopFaultsPage({
    required AppLocale locale,
    int limit = 20,
    String? cursor,
  }) async {
    if (error != null) throw error!;
    return page!;
  }
}

class _FakeLookupRepository extends LookupRepository {
  _FakeLookupRepository({this.result});

  LookupSearchResult? result;

  @override
  Future<LookupSearchResult> search({
    required String brand,
    required String model,
    required int year,
    required String engine,
    required FuelOption fuel,
    int? doors,
    required AppLocale locale,
  }) async => result!;
}

const _openableFault = TopFault(
  id: 'f1',
  title: 'Oil leak',
  severity: IssueSeverity.medium,
  reportCount: 12,
  vehicleBrand: 'BMW',
  vehicleModel: '320d',
  vehicleYearFrom: 2012,
  vehicleEngine: '2.0d',
  vehicleFuelType: 'diesel',
  vehicleDoors: 4,
);

const _faultWithNoFuelType = TopFault(
  id: 'f2',
  title: 'Turbo failure',
  severity: IssueSeverity.high,
  reportCount: 30,
  vehicleBrand: 'Audi',
  vehicleModel: 'A4',
  vehicleYearFrom: 2014,
  vehicleEngine: '2.0 TFSI',
);

const _faultWithNoEngine = TopFault(
  id: 'f3',
  title: 'Suspension noise',
  severity: IssueSeverity.low,
  reportCount: 8,
  vehicleBrand: 'Renault',
  vehicleModel: 'Clio',
  vehicleYearFrom: 2010,
);

Widget _app(DefectsViewModel viewModel) {
  return MultiProvider(
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
      home: DefectsView(viewModel: viewModel),
    ),
  );
}

void main() {
  testWidgets('shows a card per loaded fault', (WidgetTester tester) async {
    final viewModel = DefectsViewModel(
      repository: _FakePlatformRepository(
        page: const TopFaultsPage(
          items: [_openableFault, _faultWithNoFuelType],
          nextCursor: null,
        ),
      ),
    );

    await tester.pumpWidget(_app(viewModel));
    await tester.pumpAndSettle();

    expect(find.byType(TopFaultCard), findsNWidgets(2));
    expect(find.text('BMW 320d'), findsOneWidget);
    expect(find.text('Audi A4'), findsOneWidget);
  });

  testWidgets('shows the error state with a retry button', (
    WidgetTester tester,
  ) async {
    final viewModel = DefectsViewModel(
      repository: _FakePlatformRepository(error: Exception('offline')),
    );

    await tester.pumpWidget(_app(viewModel));
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível carregar os defeitos.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('shows the empty state when there are no faults', (
    WidgetTester tester,
  ) async {
    final viewModel = DefectsViewModel(
      repository: _FakePlatformRepository(
        page: const TopFaultsPage(items: [], nextCursor: null),
      ),
    );

    await tester.pumpWidget(_app(viewModel));
    await tester.pumpAndSettle();

    expect(find.text('Ainda não há avarias reportadas.'), findsOneWidget);
  });

  testWidgets(
    'tapping a fault with a known fuel type opens its lookup results',
    (WidgetTester tester) async {
      final viewModel = DefectsViewModel(
        repository: _FakePlatformRepository(
          page: const TopFaultsPage(items: [_openableFault], nextCursor: null),
        ),
        lookupRepository: _FakeLookupRepository(
          result: LookupSearchSuccess(
            vehicle: LookupDemoDisplay.vehicle,
            issues: LookupDemoDisplay.issues,
          ),
        ),
      );

      await tester.pumpWidget(_app(viewModel));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TopFaultCard));
      await tester.pumpAndSettle();

      expect(find.byType(LookupResultsView), findsOneWidget);
    },
  );

  testWidgets(
    'a fault with no fuel type on record still opens, falling back to petrol',
    (WidgetTester tester) async {
      final viewModel = DefectsViewModel(
        repository: _FakePlatformRepository(
          page: const TopFaultsPage(
            items: [_faultWithNoFuelType],
            nextCursor: null,
          ),
        ),
        lookupRepository: _FakeLookupRepository(
          result: LookupSearchSuccess(
            vehicle: LookupDemoDisplay.vehicle,
            issues: LookupDemoDisplay.issues,
          ),
        ),
      );

      await tester.pumpWidget(_app(viewModel));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TopFaultCard));
      await tester.pumpAndSettle();

      expect(find.byType(LookupResultsView), findsOneWidget);
    },
  );

  testWidgets('a fault with no engine on record is not tappable', (
    WidgetTester tester,
  ) async {
    final viewModel = DefectsViewModel(
      repository: _FakePlatformRepository(
        page: const TopFaultsPage(
          items: [_faultWithNoEngine],
          nextCursor: null,
        ),
      ),
    );

    await tester.pumpWidget(_app(viewModel));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(TopFaultCard),
        matching: find.byType(InkWell),
      ),
      findsNothing,
    );

    await tester.tap(find.byType(TopFaultCard));
    await tester.pumpAndSettle();

    expect(find.byType(DefectsView), findsOneWidget);
    expect(find.byType(LookupResultsView), findsNothing);
  });
}
