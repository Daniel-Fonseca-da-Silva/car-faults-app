import 'package:car_faults_app/data/repositories/favorites_repository.dart';
import 'package:car_faults_app/domain/models/favorite_vehicle.dart';
import 'package:car_faults_app/ui/features/favorites/view_models/favorites_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

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

const _otherVehicle = FavoriteVehicle(
  vehicleModelId: 'vm-2',
  brand: 'Volkswagen',
  model: 'Polo',
  year: 1998,
  engine: '1.0',
  fuelType: 'gasoline',
  doors: 5,
  imageUrl: null,
);

class _FakeFavoritesRepository extends FavoritesRepository {
  _FakeFavoritesRepository({this.vehicles, this.unfavoriteSucceeds = true});

  List<FavoriteVehicle>? vehicles;
  bool unfavoriteSucceeds;

  var unfavoriteCalls = <(String, int)>[];

  @override
  Future<List<FavoriteVehicle>?> fetchFavorites({int? limit}) async => vehicles;

  @override
  Future<bool> unfavorite({
    required String vehicleModelId,
    required int year,
  }) async {
    unfavoriteCalls.add((vehicleModelId, year));
    return unfavoriteSucceeds;
  }
}

void main() {
  group('load', () {
    test('loads the first page of favorites', () async {
      final viewModel = FavoritesViewModel(
        repository: _FakeFavoritesRepository(vehicles: const [_vehicle]),
      );

      await viewModel.load();

      expect(viewModel.vehicles, hasLength(1));
      expect(viewModel.vehicles.single.vehicleModelId, 'vm-1');
      expect(viewModel.hasError, isFalse);
    });

    test('sets hasError when the request fails', () async {
      final viewModel = FavoritesViewModel(
        repository: _FakeFavoritesRepository(vehicles: null),
      );

      await viewModel.load();

      expect(viewModel.hasError, isTrue);
      expect(viewModel.vehicles, isEmpty);
    });

    test('ignores a second call while one is in flight', () async {
      final repository = _FakeFavoritesRepository(vehicles: const [_vehicle]);
      final viewModel = FavoritesViewModel(repository: repository);

      final first = viewModel.load();
      final second = viewModel.load();
      await first;
      await second;

      expect(viewModel.vehicles, hasLength(1));
    });
  });

  group('removeFavorite', () {
    test('removes the vehicle from the list on success', () async {
      final viewModel = FavoritesViewModel(
        repository: _FakeFavoritesRepository(
          vehicles: const [_vehicle, _otherVehicle],
        ),
      );
      await viewModel.load();

      await viewModel.removeFavorite(_vehicle);

      expect(viewModel.vehicles, hasLength(1));
      expect(viewModel.vehicles.single.vehicleModelId, 'vm-2');
      expect(viewModel.removeFailed, isFalse);
    });

    test(
      'sets removeFailed and keeps the vehicle when the call fails',
      () async {
        final viewModel = FavoritesViewModel(
          repository: _FakeFavoritesRepository(
            vehicles: const [_vehicle],
            unfavoriteSucceeds: false,
          ),
        );
        await viewModel.load();

        await viewModel.removeFavorite(_vehicle);

        expect(viewModel.removeFailed, isTrue);
        expect(viewModel.vehicles, hasLength(1));
      },
    );

    test('acknowledgeRemoveFailure clears removeFailed', () async {
      final viewModel = FavoritesViewModel(
        repository: _FakeFavoritesRepository(
          vehicles: const [_vehicle],
          unfavoriteSucceeds: false,
        ),
      );
      await viewModel.load();
      await viewModel.removeFavorite(_vehicle);

      viewModel.acknowledgeRemoveFailure();

      expect(viewModel.removeFailed, isFalse);
    });
  });
}
