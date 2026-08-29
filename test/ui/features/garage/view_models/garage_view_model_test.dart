import 'package:car_faults_app/ui/features/garage/garage_demo_display.dart';
import 'package:car_faults_app/ui/features/garage/view_models/garage_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default: one Fiat Punto vehicle, selected, with its 3 issues', () {
    final viewModel = GarageViewModel();

    expect(viewModel.vehicles, hasLength(1));
    expect(viewModel.vehicles.single.id, 'fiat-punto-2001');
    expect(viewModel.selectedVehicle?.id, 'fiat-punto-2001');
    expect(viewModel.issues, hasLength(3));
  });

  test('empty vehicles: no selected vehicle and no issues', () {
    final viewModel = GarageViewModel(vehicles: []);

    expect(viewModel.selectedVehicle, isNull);
    expect(viewModel.issues, isEmpty);
  });

  test('removeVehicle removes the only vehicle and clears the selection', () {
    final viewModel = GarageViewModel();

    viewModel.removeVehicle('fiat-punto-2001');

    expect(viewModel.vehicles, isEmpty);
    expect(viewModel.selectedVehicle, isNull);
    expect(viewModel.issues, isEmpty);
  });

  test('removeVehicle notifies listeners', () {
    final viewModel = GarageViewModel();
    var notified = false;
    viewModel.addListener(() => notified = true);

    viewModel.removeVehicle('fiat-punto-2001');

    expect(notified, isTrue);
  });

  test('removeVehicle ignores an unknown id', () {
    final viewModel = GarageViewModel();

    viewModel.removeVehicle('unknown-id');

    expect(viewModel.vehicles, hasLength(1));
  });

  test('vehicles is not affected by mutating the demo constant', () {
    final viewModel = GarageViewModel();

    viewModel.removeVehicle('fiat-punto-2001');

    expect(GarageDemoDisplay.vehicles, hasLength(1));
  });

  test('injected vehicles and issues override the demo defaults', () {
    final viewModel = GarageViewModel(
      vehicles: const [],
      issues: GarageDemoDisplay.issues,
    );

    expect(viewModel.selectedVehicle, isNull);
    expect(viewModel.issues, isEmpty);
  });
}
