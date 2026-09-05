import 'dart:async';

import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/repositories/lookup_repository.dart';
import 'package:car_faults_app/data/repositories/platform_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/domain/models/app_locale.dart';
import 'package:car_faults_app/domain/models/platform_stats.dart';
import 'package:car_faults_app/domain/models/top_fault.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/main.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/core/widgets/app_footer.dart';
import 'package:car_faults_app/ui/core/widgets/app_header.dart';
import 'package:car_faults_app/ui/core/widgets/app_menu_button.dart';
import 'package:car_faults_app/ui/core/widgets/brand_wordmark.dart';
import 'package:car_faults_app/ui/features/home/home_search_options.dart';
import 'package:car_faults_app/ui/features/home/view_models/home_search_view_model.dart';
import 'package:car_faults_app/ui/features/home/views/home_view.dart';
import 'package:car_faults_app/ui/features/home/views/widgets/home_search_card.dart';
import 'package:car_faults_app/ui/features/login/views/login_view.dart';
import 'package:car_faults_app/ui/features/lookup/lookup_demo_display.dart';
import 'package:car_faults_app/ui/features/lookup/views/lookup_results_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeLookupRepository extends LookupRepository {
  _FakeLookupRepository({this.onSearch});

  final Future<LookupSearchResult> Function()? onSearch;

  @override
  Future<LookupSearchResult> search({
    required String brand,
    required String model,
    required int year,
    required String engine,
    required FuelOption fuel,
    int? doors,
    required AppLocale locale,
  }) async {
    if (onSearch != null) return onSearch!();
    return const LookupSearchSuccess(
      vehicle: LookupDemoDisplay.vehicle,
      issues: LookupDemoDisplay.issues,
    );
  }
}

class _FakePlatformRepository extends PlatformRepository {
  @override
  Future<PlatformStats> getStats() async {
    return const PlatformStats(
      faultsCount: 0,
      vehiclesCount: 0,
      reportsCount: 0,
    );
  }

  @override
  Future<List<TopFault>> getTopFaults({
    required AppLocale locale,
    int limit = 6,
  }) async {
    return const [];
  }
}

Widget _app() {
  return CarFaultsApp(
    lookupRepository: _FakeLookupRepository(),
    platformRepository: _FakePlatformRepository(),
  );
}

Widget _homeApp({required HomeSearchViewModel viewModel}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => LocaleViewModel(
          repository: LocaleRepository(service: LocalePreferencesService()),
        ),
      ),
      ChangeNotifierProvider(create: (_) => AuthSessionViewModel()),
      Provider<LookupRepository>.value(value: _FakeLookupRepository()),
      Provider<PlatformRepository>.value(value: _FakePlatformRepository()),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomeView(viewModel: viewModel),
    ),
  );
}

void _fillRequired(HomeSearchViewModel viewModel) {
  viewModel
    ..setBrand('Volkswagen')
    ..setModel('Polo')
    ..setYear(1996)
    ..setEngine('1.6')
    ..setFuel(FuelOption.petrol);
}

Future<void> _tapSearch(WidgetTester tester) async {
  final button = find.descendant(
    of: find.byType(HomeSearchCard),
    matching: find.text('Pesquisar defeitos'),
  );
  await tester.ensureVisible(button);
  await tester.tap(button);
}

void main() {
  testWidgets('HomeView shows AppHeader and AppFooter', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppHeader),
        matching: find.byType(BrandWordmark),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(AppFooter),
        matching: find.byType(BrandWordmark),
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Dados obtidos de relatos públicos e entidades reguladoras. '
        'Não substitui uma avaliação técnica.',
      ),
      findsOneWidget,
    );
    expect(find.text('© 2026'), findsOneWidget);
  });

  testWidgets('HomeView shows the vehicle search card', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.byType(HomeSearchCard), findsOneWidget);
    expect(find.text('PESQUISAR VEÍCULO'), findsOneWidget);
  });

  testWidgets('opening the menu and tapping Entrar opens the LoginView', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.text('Entrar na conta'), findsOneWidget);
  });

  testWidgets('searching shows the loading copy until results open', (
    WidgetTester tester,
  ) async {
    final gate = Completer<LookupSearchResult>();
    final viewModel = HomeSearchViewModel(
      repository: _FakeLookupRepository(onSearch: () => gate.future),
    );
    _fillRequired(viewModel);

    await tester.pumpWidget(_homeApp(viewModel: viewModel));
    await tester.pumpAndSettle();
    await _tapSearch(tester);
    await tester.pump();

    expect(find.text('A analisar o veículo…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(HomeSearchCard), findsNothing);

    gate.complete(
      const LookupSearchSuccess(
        vehicle: LookupDemoDisplay.vehicle,
        issues: LookupDemoDisplay.issues,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LookupResultsView), findsOneWidget);
    expect(find.text('Nova busca'), findsOneWidget);
  });

  testWidgets('search with an instant delay pushes LookupResultsView', (
    WidgetTester tester,
  ) async {
    final viewModel = HomeSearchViewModel(repository: _FakeLookupRepository());
    _fillRequired(viewModel);

    await tester.pumpWidget(_homeApp(viewModel: viewModel));
    await tester.pumpAndSettle();
    await _tapSearch(tester);
    await tester.pumpAndSettle();

    expect(find.byType(LookupResultsView), findsOneWidget);
  });
}
