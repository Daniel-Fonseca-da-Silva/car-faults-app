import 'dart:async';

import 'package:car_faults_app/data/repositories/auth_repository.dart';
import 'package:car_faults_app/data/repositories/garage_repository.dart';
import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/repositories/lookup_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/domain/models/app_locale.dart';
import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:car_faults_app/domain/models/known_issue.dart';
import 'package:car_faults_app/domain/models/lookup_vehicle.dart';
import 'package:car_faults_app/domain/models/saved_vehicle.dart';
import 'package:car_faults_app/domain/models/user.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/features/garage/view_models/garage_view_model.dart';
import 'package:car_faults_app/ui/features/garage/views/garage_view.dart';
import 'package:car_faults_app/ui/features/garage/views/widgets/garage_hero_card.dart';
import 'package:car_faults_app/ui/features/home/home_search_options.dart';
import 'package:car_faults_app/ui/features/login/views/login_view.dart';
import 'package:car_faults_app/ui/features/lookup/views/lookup_results_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const _signedInUser = User(id: 'u-1', name: 'Ana', email: 'ana@example.com');

const _vehicle = SavedVehicle(
  id: 'fiat-punto-2001',
  brand: 'Fiat',
  model: 'Punto',
  name: 'Punto',
  yearFrom: 2001,
  yearTo: 2001,
  knownIssuesCount: 3,
  engine: '1.2',
);

const _issue = KnownIssue(
  id: 'timing-belt-wear',
  title: 'Timing belt wear and failure',
  description: 'Wears out early.',
  severity: IssueSeverity.high,
  sources: [],
  fixes: [],
  reviews: [],
);

const _lookupVehicle = LookupVehicle(
  id: 'vm-1',
  brand: 'Fiat',
  model: 'Punto',
  name: 'Punto',
  yearFrom: 2001,
  yearTo: 2001,
  engine: '1.2',
  doors: 3,
  fuelType: 'gasoline',
  powerHp: 60,
);

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
  }) async {
    return result ??
        const LookupSearchSuccess(vehicle: _lookupVehicle, issues: [_issue]);
  }
}

class _FakeGarageRepository extends GarageRepository {
  _FakeGarageRepository({this.vehicles});

  List<SavedVehicle>? vehicles;
  List<KnownIssue> issues = const [_issue];

  @override
  Future<List<SavedVehicle>?> fetchVehicles({
    required AppLocale locale,
  }) async => vehicles;

  @override
  Future<List<KnownIssue>?> fetchKnownIssues(
    String vehicleId, {
    required AppLocale locale,
  }) async => issues;

  @override
  Future<bool> removeVehicle(String id) async {
    vehicles = vehicles?.where((vehicle) => vehicle.id != id).toList();
    return true;
  }
}

class _FailingRemoveGarageRepository extends GarageRepository {
  _FailingRemoveGarageRepository(this.vehicles);

  List<SavedVehicle> vehicles;

  @override
  Future<List<SavedVehicle>?> fetchVehicles({
    required AppLocale locale,
  }) async => vehicles;

  @override
  Future<List<KnownIssue>?> fetchKnownIssues(
    String vehicleId, {
    required AppLocale locale,
  }) async => [];

  @override
  Future<bool> removeVehicle(String id) async => false;
}

class _DelayedGarageRepository extends GarageRepository {
  final completer = Completer<List<SavedVehicle>?>();

  @override
  Future<List<SavedVehicle>?> fetchVehicles({required AppLocale locale}) =>
      completer.future;
}

class _CountingFetchVehiclesRepository extends GarageRepository {
  int fetchCalls = 0;

  @override
  Future<List<SavedVehicle>?> fetchVehicles({required AppLocale locale}) async {
    fetchCalls++;
    return null;
  }
}

Widget _app({
  GarageRepository? repository,
  LookupRepository? lookupRepository,
  AuthSessionViewModel? authSessionViewModel,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => LocaleViewModel(
          repository: LocaleRepository(service: LocalePreferencesService()),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => authSessionViewModel ?? AuthSessionViewModel(),
      ),
      Provider<AuthRepository>.value(value: AuthRepository()),
      ChangeNotifierProvider(
        create: (_) => GarageViewModel(
          repository: repository ?? _FakeGarageRepository(),
          lookupRepository: lookupRepository ?? _FakeLookupRepository(),
          locale: AppLocale.pt,
        )..load(),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const GarageView(),
    ),
  );
}

void main() {
  testWidgets('shows a loading indicator while the vehicles load', (
    WidgetTester tester,
  ) async {
    final repository = _DelayedGarageRepository();
    await tester.pumpWidget(_app(repository: repository));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    repository.completer.complete(const [_vehicle]);
    await tester.pumpAndSettle();
  });

  testWidgets('shows the footer disclaimer', (WidgetTester tester) async {
    await tester.pumpWidget(
      _app(repository: _FakeGarageRepository(vehicles: const [_vehicle])),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Dados obtidos de relatos públicos e entidades reguladoras. '
        'Não substitui uma avaliação técnica.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loaded vehicle shows in the hero', (WidgetTester tester) async {
    await tester.pumpWidget(
      _app(repository: _FakeGarageRepository(vehicles: const [_vehicle])),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(GarageHeroCard),
        matching: find.text('Fiat Punto'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('empty garage shows the empty hero title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(repository: _FakeGarageRepository(vehicles: const [])),
    );
    await tester.pumpAndSettle();

    expect(find.text('A sua garagem está vazia'), findsOneWidget);
  });

  testWidgets('shows an error state with a retry button when loading fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(repository: _FakeGarageRepository()));
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível carregar a sua garagem.'),
      findsOneWidget,
    );
    expect(find.byType(GarageHeroCard), findsNothing);
  });

  testWidgets(
    'removing the only vehicle empties the hero and the vehicles list',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _app(repository: _FakeGarageRepository(vehicles: const [_vehicle])),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('A sua garagem está vazia'), findsOneWidget);
      expect(find.text('Ainda não tem veículos na garagem.'), findsOneWidget);
      expect(find.text('Fiat Punto'), findsNothing);
    },
  );

  testWidgets('default view model shows the known issues section', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(repository: _FakeGarageRepository(vehicles: const [_vehicle])),
    );
    await tester.pumpAndSettle();

    expect(find.text('DEFEITOS CONHECIDOS'), findsOneWidget);
    expect(find.text('Timing belt wear and failure'), findsOneWidget);
  });

  testWidgets('removing the only vehicle hides the known issues section', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(repository: _FakeGarageRepository(vehicles: const [_vehicle])),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('DEFEITOS CONHECIDOS'), findsNothing);
  });

  testWidgets('a failed removal shows an error SnackBar and keeps the '
      'vehicle', (WidgetTester tester) async {
    await tester.pumpWidget(
      _app(repository: _FailingRemoveGarageRepository(const [_vehicle])),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível remover o veículo. Tente novamente.'),
      findsOneWidget,
    );
    // Hero + vehicles list both keep the name when removal fails.
    expect(find.text('Fiat Punto'), findsNWidgets(2));
  });

  testWidgets('retry redirects to sign-in when the session was cleared', (
    WidgetTester tester,
  ) async {
    final signedOutSession = AuthSessionViewModel();
    await tester.pumpWidget(
      _app(
        repository: _FakeGarageRepository(),
        authSessionViewModel: signedOutSession,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
  });

  testWidgets('retry reloads when still signed in', (
    WidgetTester tester,
  ) async {
    final signedInSession = AuthSessionViewModel()..setUser(_signedInUser);
    final repository = _CountingFetchVehiclesRepository();
    await tester.pumpWidget(
      _app(repository: repository, authSessionViewModel: signedInSession),
    );
    await tester.pumpAndSettle();
    expect(repository.fetchCalls, 1);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(repository.fetchCalls, 2);
    expect(find.byType(LoginView), findsNothing);
  });

  testWidgets('tapping "Ver detalhes" opens the real vehicle results', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        repository: _FakeGarageRepository(vehicles: const [_vehicle]),
        lookupRepository: _FakeLookupRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Ver detalhes'));
    await tester.tap(find.text('Ver detalhes'));
    await tester.pumpAndSettle();

    expect(find.byType(LookupResultsView), findsOneWidget);
  });

  testWidgets('a failed lookup shows an error SnackBar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        repository: _FakeGarageRepository(vehicles: const [_vehicle]),
        lookupRepository: _FakeLookupRepository(
          result: const LookupSearchFailure(LookupFailureReason.notFound),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Ver detalhes'));
    await tester.tap(find.text('Ver detalhes'));
    await tester.pumpAndSettle();

    expect(find.text('Veículo não encontrado.'), findsOneWidget);
  });
}
