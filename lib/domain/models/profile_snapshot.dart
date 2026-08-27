import 'saved_vehicle.dart';
import 'user.dart';
import 'user_stats.dart';

/// Full profile data shown on the profile screen: account holder, account
/// dates, usage stats and saved vehicles.
class ProfileSnapshot {
  const ProfileSnapshot({
    required this.user,
    required this.createdAt,
    required this.updatedAt,
    required this.stats,
    required this.vehicles,
  });

  final User user;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserStats stats;
  final List<SavedVehicle> vehicles;
}
