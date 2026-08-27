import 'package:car_faults_app/ui/features/profile/profile_demo_display.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('user is Ana Silva', () {
    final user = ProfileDemoDisplay.snapshot.user;

    expect(user.name, 'Ana Silva');
    expect(user.email, 'ana@example.com');
    expect(user.photoUrl, isNull);
  });

  test('has the 4 activity stats', () {
    final stats = ProfileDemoDisplay.snapshot.stats;

    expect(stats.searchesCount, 47);
    expect(stats.defectsConsultedCount, 128);
    expect(stats.savedVehiclesCount, 6);
    expect(stats.votesCount, 23);
  });

  test('has exactly 3 saved vehicles', () {
    expect(ProfileDemoDisplay.snapshot.vehicles, hasLength(3));
    expect(ProfileDemoDisplay.snapshot.vehicles.first.name, 'Polo 6N1');
  });
}
