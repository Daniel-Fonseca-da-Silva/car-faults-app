import 'package:dio/dio.dart';

/// Talks to `car-faults-api`'s community fix-vote endpoints.
class FixesApiService {
  FixesApiService({required this.dio});

  final Dio dio;

  /// `POST /v1/fixes/:id/vote` — JWT required. [value] is `'like'` or
  /// `'dislike'` (`FixVoteValue`'s API values).
  Future<Map<String, dynamic>> vote({
    required String fixId,
    required String value,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/v1/fixes/$fixId/vote',
      data: {'value': value},
    );
    return response.data!;
  }

  /// `DELETE /v1/fixes/:id/vote` — JWT required.
  Future<void> removeVote({required String fixId}) async {
    await dio.delete<void>('/v1/fixes/$fixId/vote');
  }
}
