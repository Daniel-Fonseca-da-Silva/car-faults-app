import 'package:dio/dio.dart';

/// Talks to `car-faults-api`'s community comment endpoints.
class CommentsApiService {
  CommentsApiService({required this.dio});

  final Dio dio;

  /// `GET /v1/comments?knownIssueId=` — public. Fetches the first page only,
  /// at the API's default page size.
  Future<Map<String, dynamic>> list({required String knownIssueId}) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/v1/comments',
      queryParameters: {'knownIssueId': knownIssueId},
    );
    return response.data!;
  }

  /// `POST /v1/comments` — JWT required.
  Future<Map<String, dynamic>> create({
    required String knownIssueId,
    required String body,
    String? imageUrl,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/v1/comments',
      data: {'knownIssueId': knownIssueId, 'body': body, 'imageUrl': ?imageUrl},
    );
    return response.data!;
  }

  /// `DELETE /v1/comments/:id` — JWT required, own comment only.
  Future<void> remove(String id) async {
    await dio.delete<void>('/v1/comments/$id');
  }
}
