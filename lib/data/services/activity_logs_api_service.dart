import 'package:dio/dio.dart';

/// Talks to `car-faults-api`'s `/v1/activity-logs` endpoint.
class ActivityLogsApiService {
  ActivityLogsApiService({required this.dio});

  final Dio dio;

  /// `POST /v1/activity-logs` — JWT required. [type] is `'defect_consulted'`
  /// or `'vehicle_favorite'` (`ActivityLogType`'s API values); [year] is
  /// required only for `'vehicle_favorite'`.
  Future<Map<String, dynamic>> create({
    required String type,
    required String resourceId,
    int? year,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/v1/activity-logs',
      data: {'type': type, 'resourceId': resourceId, 'year': ?year},
    );
    return response.data!;
  }

  /// `GET /v1/activity-logs/favorites/:vehicleModelId?year=` — JWT required.
  Future<Map<String, dynamic>> getFavoriteStatus({
    required String vehicleModelId,
    required int year,
  }) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/v1/activity-logs/favorites/$vehicleModelId',
      queryParameters: {'year': year},
    );
    return response.data!;
  }

  /// `GET /v1/activity-logs/favorites?limit=` — JWT required. Fetches one
  /// page.
  Future<Map<String, dynamic>> listFavorites({int? limit}) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/v1/activity-logs/favorites',
      queryParameters: {'limit': ?limit},
    );
    return response.data!;
  }

  /// `DELETE /v1/activity-logs/favorites/:vehicleModelId?year=` — JWT
  /// required.
  Future<void> unfavorite({
    required String vehicleModelId,
    required int year,
  }) async {
    await dio.delete<void>(
      '/v1/activity-logs/favorites/$vehicleModelId',
      queryParameters: {'year': year},
    );
  }
}
