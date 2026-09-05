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
}
