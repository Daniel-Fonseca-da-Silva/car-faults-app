import 'package:car_faults_app/data/mappers/favorites_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

const _favoriteJson = {
  'id': 'log-1',
  'vehicleModelId': 'vm-1',
  'year': 2001,
  'brand': 'Volkswagen',
  'model': 'Polo',
  'engine': '1.0',
  'fuelType': 'gasoline',
  'doors': 3,
  'imageUrl': 'https://cdn.example.test/vw-polo.webp',
  'favoritedAt': '2026-07-27T10:00:00.000Z',
};

void main() {
  group('mapFavoriteVehicle', () {
    test('maps a FavoriteVehicleResponseDto JSON entry', () {
      final vehicle = mapFavoriteVehicle(_favoriteJson);

      expect(vehicle.vehicleModelId, 'vm-1');
      expect(vehicle.year, 2001);
      expect(vehicle.brand, 'Volkswagen');
      expect(vehicle.model, 'Polo');
      expect(vehicle.engine, '1.0');
      expect(vehicle.fuelType, 'gasoline');
      expect(vehicle.doors, 3);
      expect(vehicle.imageUrl, 'https://cdn.example.test/vw-polo.webp');
    });

    test('maps null fuelType, doors and imageUrl', () {
      final vehicle = mapFavoriteVehicle({
        ..._favoriteJson,
        'fuelType': null,
        'doors': null,
        'imageUrl': null,
      });

      expect(vehicle.fuelType, isNull);
      expect(vehicle.doors, isNull);
      expect(vehicle.imageUrl, isNull);
    });
  });
}
