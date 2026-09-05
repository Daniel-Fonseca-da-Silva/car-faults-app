import 'package:dio/dio.dart';

import '../../domain/models/profile_snapshot.dart';
import '../../domain/models/saved_vehicle.dart';
import '../../domain/models/user.dart';
import '../../domain/models/user_stats.dart';
import '../services/api_client.dart';
import '../services/secure_token_storage.dart';
import '../services/user_vehicles_api_service.dart';
import '../services/users_api_service.dart';

/// Loads the profile screen's snapshot from `car-faults-api`: the signed-in
/// user, activity stats and the first page of saved vehicles.
///
/// Every parameter can be overridden — tests subclass [ProfileRepository]
/// and override [fetchSnapshot] instead of injecting fakes here, but the
/// seam is kept for callers that do want to swap a dependency.
class ProfileRepository {
  ProfileRepository({
    UsersApiService? usersApiService,
    UserVehiclesApiService? userVehiclesApiService,
    SecureTokenStorage? tokenStorage,
  }) : _usersApiService =
           usersApiService ??
           UsersApiService(
             dio: buildApiDio(
               tokenStorage: tokenStorage ?? SecureTokenStorage(),
             ),
           ),
       _userVehiclesApiService =
           userVehiclesApiService ??
           UserVehiclesApiService(
             dio: buildApiDio(
               tokenStorage: tokenStorage ?? SecureTokenStorage(),
             ),
           );

  final UsersApiService _usersApiService;
  final UserVehiclesApiService _userVehiclesApiService;

  /// Combines `GET /v1/users/me`, `GET /v1/users/me/stats` and the first
  /// page of `GET /v1/user-vehicles`. Returns `null` on failure.
  Future<ProfileSnapshot?> fetchSnapshot() async {
    try {
      final userJson = await _usersApiService.getMe();
      final statsJson = await _usersApiService.getStats();
      final vehiclesJson = await _userVehiclesApiService.list();
      final items = vehiclesJson['items'] as List<dynamic>;

      return ProfileSnapshot(
        user: User.fromJson(userJson),
        createdAt: DateTime.parse(userJson['createdAt'] as String),
        updatedAt: DateTime.parse(userJson['updatedAt'] as String),
        stats: UserStats(
          searchesCount: statsJson['searchesCount'] as int,
          defectsConsultedCount: statsJson['defectsConsultedCount'] as int,
          savedVehiclesCount: statsJson['savedVehiclesCount'] as int,
          votesCount: statsJson['votesCount'] as int,
        ),
        vehicles: items
            .map(
              (item) => SavedVehicle.fromUserVehicleJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(),
      );
    } on DioException {
      return null;
    }
  }
}
