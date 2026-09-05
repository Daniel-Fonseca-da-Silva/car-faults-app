import 'package:dio/dio.dart';

/// Talks to `car-faults-api`'s community review endpoints.
class ReviewsApiService {
  ReviewsApiService({required this.dio});

  final Dio dio;

  /// `GET /v1/reviews?knownIssueId=` — public. Fetches the first page only,
  /// at the API's default page size.
  Future<Map<String, dynamic>> list({required String knownIssueId}) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/v1/reviews',
      queryParameters: {'knownIssueId': knownIssueId},
    );
    return response.data!;
  }

  /// `POST /v1/reviews` — JWT required.
  Future<Map<String, dynamic>> create({
    required String knownIssueId,
    required int rating,
    String? comment,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/v1/reviews',
      data: {
        'knownIssueId': knownIssueId,
        'rating': rating,
        'comment': ?comment,
      },
    );
    return response.data!;
  }
}
