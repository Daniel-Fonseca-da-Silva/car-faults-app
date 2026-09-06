import 'dart:async';

import 'package:car_faults_app/data/repositories/favorites_repository.dart';
import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/domain/models/favorite_vehicle.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/features/favorites/view_models/favorites_view_model.dart';
import 'package:car_faults_app/ui/features/favorites/views/favorites_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const _vehicle = FavoriteVehicle(
  vehicleModelId: 'vm-1',
  brand: 'Fiat',
  model: 'Punto',
  year: 2001,
  engine: '1.2',
  fuelType: 'gasoline',
  doors: 3,
  imageUrl: null,
);

class _FakeFavoritesRepository extends FavoritesRepository {
  _FakeFavoritesRepository({this.vehicles});

  List<FavoriteVehicle>? vehicles;

  @override
  Future<List<FavoriteVehicle>?> fetchFavorites({int? limit}) async => vehicles;

  @override
  Future<bool> unfavorite({
    required String vehicleModelId,
    required int year,
  }) async {
    vehicles = vehicles
        ?.where((vehicle) => vehicle.vehicleModelId != vehicleModelId)
        .toList();
    return true;
  }
}

class _FailingUnfavoriteRepository extends FavoritesRepository {
  _FailingUnfavoriteRepository(this.vehicles);

  List<FavoriteVehicle> vehicles;

  @override
  Future<List<FavoriteVehicle>?> fetchFavorites({int? limit}) async => vehicles;

  @override
  Future<bool> unfavorite({
    required String vehicleModelId,
    required int year,
  }) async => false;
}

class _DelayedFavoritesRepository extends FavoritesRepository {
  final completer = Completer<List<FavoriteVehicle>?>();

  @override
  Future<List<FavoriteVehicle>?> fetchFavorites({int? limit}) =>
      completer.future;
}

Widget _app({FavoritesRepository? repository}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => LocaleViewModel(
          repository: LocaleRepository(service: LocalePreferencesService()),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => FavoritesViewModel(
          repository: repository ?? _FakeFavoritesRepository(),
        )..load(),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const FavoritesView(),
    ),
  );
}

void main() {
  testWidgets('shows a loading indicator while the favorites load', (
    WidgetTester tester,
  ) async {
    final repository = _DelayedFavoritesRepository();
    await tester.pumpWidget(_app(repository: repository));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    repository.completer.complete(const [_vehicle]);
    await tester.pumpAndSettle();
  });

  testWidgets('shows the favorited vehicle', (WidgetTester tester) async {
    await tester.pumpWidget(
      _app(repository: _FakeFavoritesRepository(vehicles: const [_vehicle])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fiat Punto'), findsOneWidget);
    expect(find.text('2001'), findsOneWidget);
  });

  testWidgets('empty favorites shows the empty state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(repository: _FakeFavoritesRepository(vehicles: const [])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ainda não tens veículos favoritos.'), findsOneWidget);
  });

  testWidgets('shows an error state with a retry button when loading fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(repository: _FakeFavoritesRepository()));
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível carregar os teus favoritos.'),
      findsOneWidget,
    );
  });

  testWidgets('removing the only favorite empties the list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(repository: _FakeFavoritesRepository(vehicles: const [_vehicle])),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();

    expect(find.text('Ainda não tens veículos favoritos.'), findsOneWidget);
    expect(find.text('Fiat Punto'), findsNothing);
  });

  testWidgets('a failed removal shows an error SnackBar and keeps the '
      'vehicle', (WidgetTester tester) async {
    await tester.pumpWidget(
      _app(repository: _FailingUnfavoriteRepository([_vehicle])),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Não foi possível remover o veículo dos favoritos. Tenta novamente.',
      ),
      findsOneWidget,
    );
    expect(find.text('Fiat Punto'), findsOneWidget);
  });
}
