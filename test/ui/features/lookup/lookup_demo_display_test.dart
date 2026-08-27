import 'package:car_faults_app/ui/core/constants/app_assets.dart';
import 'package:car_faults_app/ui/features/lookup/lookup_demo_display.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('vehicle is the Volkswagen Polo 6N1', () {
    expect(LookupDemoDisplay.vehicle.brand, 'Volkswagen');
    expect(LookupDemoDisplay.vehicle.model, 'Polo');
    expect(LookupDemoDisplay.vehicle.name, 'Polo 6N1');
  });

  test('hero image points to the citroen 2CV asset', () {
    expect(LookupDemoDisplay.vehicleImage, AppAssets.citroen2Cv);
  });

  test('has exactly 3 known issues', () {
    expect(LookupDemoDisplay.issues, hasLength(3));
  });

  test('the current user review is included among the gearbox reviews', () {
    final gearbox = LookupDemoDisplay.issues.first;

    expect(
      gearbox.reviews.any((r) => r.userId == LookupDemoDisplay.currentUserId),
      isTrue,
    );
  });
}
