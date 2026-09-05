import 'package:dio/dio.dart';

import '../../domain/models/known_issue.dart';
import '../../domain/models/saved_vehicle.dart';
import '../mappers/lookup_mapper.dart';
import '../services/api_client.dart';
import '../services/secure_token_storage.dart';
import '../services/user_vehicles_api_service.dart';

/// Outcome of [GarageRepository.addVehicle].
sealed class AddToGarageResult {
  const AddToGarageResult();
}

class AddToGarageSuccess extends AddToGarageResult {
  const AddToGarageSuccess(this.vehicle);
  final SavedVehicle vehicle;
}

/// The vehicle is already in the signed-in user's garage (`409 Conflict`).
class AddToGarageDuplicate extends AddToGarageResult {
  const AddToGarageDuplicate();
}

class AddToGarageFailure extends AddToGarageResult {
  const AddToGarageFailure();
}

/// Loads and manages the garage screen's saved vehicles via
/// `car-faults-api`'s `/v1/user-vehicles` endpoints.
///
/// Every parameter can be overridden — tests subclass [GarageRepository] and
/// override individual methods instead of injecting fakes here, but the
/// seam is kept for callers that do want to swap a dependency.
class GarageRepository {
  GarageRepository({
    UserVehiclesApiService? apiService,
    SecureTokenStorage? tokenStorage,
  }) : _apiService =
           apiService ??
           UserVehiclesApiService(
             dio: buildApiDio(
               tokenStorage: tokenStorage ?? SecureTokenStorage(),
             ),
           );

  final UserVehiclesApiService _apiService;

  /// `GET /v1/user-vehicles` — first page only. Returns `null` on failure.
  Future<List<SavedVehicle>?> fetchVehicles() async {
    try {
      final json = await _apiService.list();
      final items = json['items'] as List<dynamic>;
      return items
          .map(
            (item) =>
                SavedVehicle.fromUserVehicleJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException {
      return null;
    }
  }

  /// `GET /v1/user-vehicles/:id` — the selected vehicle's known issues.
  /// Returns `null` on failure.
  Future<List<KnownIssue>?> fetchKnownIssues(String vehicleId) async {
    try {
      final json = await _apiService.getById(vehicleId);
      final issuesJson = json['knownIssues'] as List<dynamic>;
      return issuesJson
          .map((issue) => mapKnownIssue(issue as Map<String, dynamic>))
          .toList();
    } on DioException {
      return null;
    }
  }

  /// `DELETE /v1/user-vehicles/:id`. Returns `true` on success.
  Future<bool> removeVehicle(String id) async {
    try {
      await _apiService.remove(id);
      return true;
    } on DioException {
      return false;
    }
  }

  /// `GET /v1/user-vehicles/status`. Returns `null` on failure.
  Future<bool?> checkGarageStatus({
    required String vehicleModelId,
    required int year,
  }) async {
    try {
      final json = await _apiService.status(
        vehicleModelId: vehicleModelId,
        year: year,
      );
      return json['owned'] as bool;
    } on DioException {
      return null;
    }
  }

  /// `POST /v1/user-vehicles`, adding a catalog vehicle to the garage.
  Future<AddToGarageResult> addVehicle({
    required String vehicleModelId,
    required int year,
  }) async {
    try {
      final json = await _apiService.create(
        vehicleModelId: vehicleModelId,
        year: year,
      );
      return AddToGarageSuccess(SavedVehicle.fromUserVehicleJson(json));
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) return const AddToGarageDuplicate();
      return const AddToGarageFailure();
    }
  }
}
