import 'package:dio/dio.dart';

/// Talks to `car-faults-api`'s `/v1/user-vehicles` endpoints (the user's
/// garage).
class UserVehiclesApiService {
  UserVehiclesApiService({required this.dio});

  final Dio dio;

  /// `GET /v1/user-vehicles` — JWT required. Fetches one page.
  Future<Map<String, dynamic>> list({
    String? language,
    String? cursor,
    int? limit,
  }) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/v1/user-vehicles',
      queryParameters: {
        'language': ?language,
        'cursor': ?cursor,
        'limit': ?limit,
      },
    );
    return response.data!;
  }

  /// `GET /v1/user-vehicles/:id` — JWT required. Includes `knownIssues[]`.
  Future<Map<String, dynamic>> getById(String id, {String? language}) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/v1/user-vehicles/$id',
      queryParameters: {'language': ?language},
    );
    return response.data!;
  }

  /// `GET /v1/user-vehicles/status?vehicleModelId=&year=` — JWT required.
  Future<Map<String, dynamic>> status({
    required String vehicleModelId,
    required int year,
  }) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/v1/user-vehicles/status',
      queryParameters: {'vehicleModelId': vehicleModelId, 'year': year},
    );
    return response.data!;
  }

  /// `POST /v1/user-vehicles` — JWT required. Adds a catalog vehicle
  /// ([vehicleModelId]) to the signed-in user's garage. `409 Conflict` if
  /// it's already there.
  Future<Map<String, dynamic>> create({
    required String vehicleModelId,
    required int year,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/v1/user-vehicles',
      data: {'vehicleModelId': vehicleModelId, 'year': year},
    );
    return response.data!;
  }

  /// `DELETE /v1/user-vehicles/:id` — JWT required.
  Future<void> remove(String id) async {
    await dio.delete<void>('/v1/user-vehicles/$id');
  }
}
