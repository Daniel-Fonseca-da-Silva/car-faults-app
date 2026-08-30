import 'package:dio/dio.dart';

import '../../domain/models/user.dart';

/// Talks to `car-faults-api`'s mobile Google auth endpoints.
class AuthApiService {
  AuthApiService({required this.dio});

  final Dio dio;

  /// Exchanges a Google ID token for the API's JWT and the signed-in user.
  ///
  /// `POST /v1/auth/google/mobile` — contract documented in
  /// prompts/login-google-android.md. `car-faults-api` only exposes the web
  /// cookie-based `/v1/auth/google` flow today; this endpoint needs to be
  /// added there before this call can succeed.
  Future<({String accessToken, User user})> loginWithGoogle(
    String idToken,
  ) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/v1/auth/google/mobile',
      data: {'idToken': idToken},
    );
    final data = response.data!;
    return (
      accessToken: data['accessToken'] as String,
      user: User.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  /// Restores the signed-in user from the stored JWT via `GET /v1/users/me`.
  Future<User> fetchCurrentUser() async {
    final response = await dio.get<Map<String, dynamic>>('/v1/users/me');
    return User.fromJson(response.data!);
  }
}
