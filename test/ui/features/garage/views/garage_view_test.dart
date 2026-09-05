import 'dart:async';

import 'package:car_faults_app/data/repositories/garage_repository.dart';
import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:car_faults_app/domain/models/known_issue.dart';
import 'package:car_faults_app/domain/models/saved_vehicle.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/features/garage/view_models/garage_view_model.dart';
import 'package:car_faults_app/ui/features/garage/views/garage_view.dart';
import 'package:car_faults_app/ui/features/garage/views/widgets/garage_hero_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const _vehicle = SavedVehicle(
  id: 'fiat-punto-2001',
  brand: 'Fiat',
  model: 'Punto',
  name: 'Punto',
  yearFrom: 2001,
  yearTo: 2001,
  knownIssuesCount: 3,
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

class _FakeGarageRepository extends GarageRepository {
  _FakeGarageRepository({this.vehicles});

  List<SavedVehicle>? vehicles;
  List<KnownIssue> issues = const [_issue];

  @override
  Future<List<SavedVehicle>?> fetchVehicles() async => vehicles;

  @override
  Future<List<KnownIssue>?> fetchKnownIssues(String vehicleId) async => issues;

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
  Future<List<SavedVehicle>?> fetchVehicles() async => vehicles;

  @override
  Future<List<KnownIssue>?> fetchKnownIssues(String vehicleId) async => [];

  @override
  Future<bool> removeVehicle(String id) async => false;
}

class _DelayedGarageRepository extends GarageRepository {
  final completer = Completer<List<SavedVehicle>?>();

  @override
  Future<List<SavedVehicle>?> fetchVehicles() => completer.future;
}

Widget _app({GarageRepository? repository}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => LocaleViewModel(
          repository: LocaleRepository(service: LocalePreferencesService()),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) =>
            GarageViewModel(repository: repository ?? _FakeGarageRepository())
              ..load(),
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
}
