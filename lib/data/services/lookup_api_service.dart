import 'package:dio/dio.dart';

/// Talks to `car-faults-api`'s vehicle fault lookup endpoint.
class LookupApiService {
  LookupApiService({required this.dio});

  final Dio dio;

  /// `GET /v1/lookups` — JWT optional. May trigger AI generation server-side
  /// for a vehicle not yet in the catalog, per `mobile-ai-policy.md`.
  Future<Map<String, dynamic>> lookup({
    required String brand,
    required String model,
    required int year,
    required String engine,
    required String fuelType,
    int? doors,
    required String language,
  }) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/v1/lookups',
      queryParameters: {
        'brand': brand,
        'model': model,
        'year': year,
        'engine': engine,
        'fuelType': fuelType,
        'doors': ?doors,
        'language': language,
      },
    );
    return response.data!;
  }
}
