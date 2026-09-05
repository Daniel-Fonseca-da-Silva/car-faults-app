import 'package:dio/dio.dart';

/// Talks to `car-faults-api`'s `/v1/users/me` endpoints: profile, activity
/// stats and account deletion.
class UsersApiService {
  UsersApiService({required this.dio});

  final Dio dio;

  /// `GET /v1/users/me` — JWT required.
  Future<Map<String, dynamic>> getMe() async {
    final response = await dio.get<Map<String, dynamic>>('/v1/users/me');
    return response.data!;
  }

  /// `GET /v1/users/me/stats` — JWT required.
  Future<Map<String, dynamic>> getStats() async {
    final response = await dio.get<Map<String, dynamic>>('/v1/users/me/stats');
    return response.data!;
  }

  /// `DELETE /v1/users/me` — JWT required. Soft-deletes the account
  /// server-side.
  Future<void> deleteMe() async {
    await dio.delete<void>('/v1/users/me');
  }
}
