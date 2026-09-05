import 'package:dio/dio.dart';

/// Talks to `car-faults-api`'s public platform stats/faults endpoints.
class PlatformApiService {
  PlatformApiService({required this.dio});

  final Dio dio;

  /// `GET /v1/platform/stats`.
  Future<Map<String, dynamic>> getStats() async {
    final response = await dio.get<Map<String, dynamic>>('/v1/platform/stats');
    return response.data!;
  }

  /// `GET /v1/platform/faults?locale=&limit=`.
  Future<Map<String, dynamic>> getFaults({
    required String locale,
    required int limit,
  }) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/v1/platform/faults',
      queryParameters: {'locale': locale, 'limit': limit},
    );
    return response.data!;
  }
}
