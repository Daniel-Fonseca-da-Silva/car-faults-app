import '../../../domain/models/profile_snapshot.dart';
import '../../../domain/models/saved_vehicle.dart';
import '../../../domain/models/user.dart';
import '../../../domain/models/user_stats.dart';

/// Mocked profile data shown on the profile screen, regardless of who is
/// signed in.
///
/// Placeholder data: there is no profile backend in this delivery.
abstract final class ProfileDemoDisplay {
  static final snapshot = ProfileSnapshot(
    user: const User(
      id: 'b3a5c1d2-4e6f-4a8b-9c0d-1e2f3a4b5c6d',
      name: 'Ana Silva',
      email: 'ana@example.com',
    ),
    createdAt: DateTime.utc(2026, 7, 17),
    updatedAt: DateTime.utc(2026, 7, 17),
    stats: const UserStats(
      searchesCount: 47,
      defectsConsultedCount: 128,
      savedVehiclesCount: 6,
      votesCount: 23,
    ),
    vehicles: const [
      SavedVehicle(
        id: 'vw-polo-6n1',
        brand: 'Volkswagen',
        model: 'Polo',
        name: 'Polo 6N1',
        yearFrom: 1994,
        yearTo: 1999,
        knownIssuesCount: 3,
      ),
      SavedVehicle(
        id: 'fiat-uno-mille',
        brand: 'Fiat',
        model: 'Uno',
        name: 'Uno Mille',
        yearFrom: 2005,
        yearTo: 2010,
        knownIssuesCount: 5,
      ),
      SavedVehicle(
        id: 'ford-fiesta',
        brand: 'Ford',
        model: 'Fiesta',
        name: 'Fiesta',
        yearFrom: 2011,
        yearTo: 2014,
        knownIssuesCount: 2,
      ),
    ],
  );
}
