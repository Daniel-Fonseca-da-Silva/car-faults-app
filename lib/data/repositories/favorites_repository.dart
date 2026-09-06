import 'package:dio/dio.dart';

import '../../domain/models/favorite_vehicle.dart';
import '../mappers/favorites_mapper.dart';
import '../services/activity_logs_api_service.dart';
import '../services/api_client.dart';
import '../services/secure_token_storage.dart';

const _favoriteType = 'vehicle_favorite';

/// Manages the signed-in user's favorited vehicles via `car-faults-api`'s
/// `/v1/activity-logs` endpoints.
///
/// Every parameter can be overridden — tests subclass [FavoritesRepository]
/// and override individual methods instead of injecting fakes here, but the
/// seam is kept for callers that do want to swap a dependency.
class FavoritesRepository {
  FavoritesRepository({
    ActivityLogsApiService? apiService,
    SecureTokenStorage? tokenStorage,
  }) : _apiService =
           apiService ??
           ActivityLogsApiService(
             dio: buildApiDio(
               tokenStorage: tokenStorage ?? SecureTokenStorage(),
             ),
           );

  final ActivityLogsApiService _apiService;

  /// `GET /v1/activity-logs/favorites/:vehicleModelId?year=`. Any failure
  /// (including being signed out) is treated as `false`, matching the web
  /// app.
  Future<bool> fetchStatus({
    required String vehicleModelId,
    required int year,
  }) async {
    try {
      final json = await _apiService.getFavoriteStatus(
        vehicleModelId: vehicleModelId,
        year: year,
      );
      return json['favorited'] as bool;
    } on DioException {
      return false;
    }
  }

  /// `POST /v1/activity-logs` with `type: 'vehicle_favorite'`. Returns
  /// `true` on success.
  Future<bool> favorite({
    required String vehicleModelId,
    required int year,
  }) async {
    try {
      await _apiService.create(
        type: _favoriteType,
        resourceId: vehicleModelId,
        year: year,
      );
      return true;
    } on DioException {
      return false;
    }
  }

  /// `DELETE /v1/activity-logs/favorites/:vehicleModelId?year=`. Returns
  /// `true` on success.
  Future<bool> unfavorite({
    required String vehicleModelId,
    required int year,
  }) async {
    try {
      await _apiService.unfavorite(vehicleModelId: vehicleModelId, year: year);
      return true;
    } on DioException {
      return false;
    }
  }

  /// `GET /v1/activity-logs/favorites` — first page only. Returns `null` on
  /// failure.
  Future<List<FavoriteVehicle>?> fetchFavorites({int? limit}) async {
    try {
      final json = await _apiService.listFavorites(limit: limit);
      final items = json['items'] as List<dynamic>;
      return items
          .map((item) => mapFavoriteVehicle(item as Map<String, dynamic>))
          .toList();
    } on DioException {
      return null;
    }
  }
}
