import 'package:car_faults_app/ui/features/profile/profile_demo_display.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('user is Ana Silva with no photo', () {
    final user = ProfileDemoDisplay.snapshot.user;

    expect(user.name, 'Ana Silva');
    expect(user.email, 'ana@example.com');
    expect(user.photoUrl, isNull);
  });

  test('has 4 usage stats', () {
    final stats = ProfileDemoDisplay.snapshot.stats;

    expect(stats.searchesCount, 47);
    expect(stats.defectsConsultedCount, 128);
    expect(stats.savedVehiclesCount, 6);
    expect(stats.votesCount, 23);
  });

  test('has exactly 3 saved vehicles', () {
    expect(ProfileDemoDisplay.snapshot.vehicles, hasLength(3));
  });

  test('created and updated dates are set', () {
    final snapshot = ProfileDemoDisplay.snapshot;

    expect(snapshot.createdAt, DateTime.utc(2026, 7, 17));
    expect(snapshot.updatedAt, DateTime.utc(2026, 7, 17));
  });
}
