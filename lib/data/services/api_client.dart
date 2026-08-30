import 'package:dio/dio.dart';

import 'api_config.dart';
import 'secure_token_storage.dart';

/// Builds the [Dio] client used for authenticated requests to
/// `car-faults-api`: attaches the stored JWT as a Bearer token on every
/// request, and clears it (notifying [onUnauthorized]) whenever the API
/// responds with 401.
Dio buildApiDio({
  required SecureTokenStorage tokenStorage,
  void Function()? onUnauthorized,
}) {
  final dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.readToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await tokenStorage.deleteToken();
          onUnauthorized?.call();
        }
        handler.next(error);
      },
    ),
  );

  return dio;
}
