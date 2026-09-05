import 'package:car_faults_app/domain/models/saved_vehicle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fromUserVehicleJson', () {
    test('maps the single year to yearFrom and yearTo', () {
      final vehicle = SavedVehicle.fromUserVehicleJson({
        'id': 'uv-1',
        'brand': 'Volkswagen',
        'model': 'Polo',
        'year': 2001,
        'engine': '1.0',
        'name': 'Meu Polo',
        'knownIssuesCount': 3,
      });

      expect(vehicle.id, 'uv-1');
      expect(vehicle.brand, 'Volkswagen');
      expect(vehicle.model, 'Polo');
      expect(vehicle.name, 'Meu Polo');
      expect(vehicle.yearFrom, 2001);
      expect(vehicle.yearTo, 2001);
      expect(vehicle.knownIssuesCount, 3);
    });

    test('falls back to "brand model" when name is null', () {
      final vehicle = SavedVehicle.fromUserVehicleJson({
        'id': 'uv-2',
        'brand': 'Fiat',
        'model': 'Punto',
        'year': 2005,
        'engine': '1.2',
        'name': null,
        'knownIssuesCount': 0,
      });

      expect(vehicle.name, 'Fiat Punto');
    });
  });
}
