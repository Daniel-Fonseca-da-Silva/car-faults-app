import 'package:dio/dio.dart';

/// Talks to `car-faults-api`'s report endpoint.
class ReportsApiService {
  ReportsApiService({required this.dio});

  final Dio dio;

  /// `POST /v1/reports` — JWT required.
  Future<Map<String, dynamic>> create({
    required String contentType,
    required String contentId,
    required String reason,
    String? details,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/v1/reports',
      data: {
        'contentType': contentType,
        'contentId': contentId,
        'reason': reason,
        'details': ?details,
      },
    );
    return response.data!;
  }
}
