import 'dart:convert';
import 'dart:typed_data';

import 'package:car_faults_app/data/services/auth_api_service.dart';
import 'package:car_faults_app/domain/models/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdapter implements HttpClientAdapter {
  RequestOptions? lastOptions;
  Object? body;
  int statusCode = 200;
  Map<String, dynamic> responseData = const {};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    if (requestStream != null) {
      final chunks = await requestStream.toList();
      final bytes = chunks.expand((chunk) => chunk).toList();
      if (bytes.isNotEmpty) {
        body = jsonDecode(utf8.decode(bytes));
      }
    }
    return ResponseBody.fromString(
      jsonEncode(responseData),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('loginWithGoogle posts the idToken and maps the session', () async {
    final adapter = _FakeAdapter()
      ..responseData = {
        'accessToken': 'jwt',
        'user': {
          'id': 'u1',
          'name': 'Ada',
          'email': 'ada@example.com',
          'avatarUrl': 'https://example.com/a.png',
        },
      };
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter;
    final service = AuthApiService(dio: dio);

    final session = await service.loginWithGoogle('google-id-token');

    expect(adapter.lastOptions?.path, '/v1/auth/google/mobile');
    expect(adapter.lastOptions?.method, 'POST');
    expect(adapter.body, {'idToken': 'google-id-token'});
    expect(session.accessToken, 'jwt');
    expect(
      session.user,
      isA<User>()
          .having((user) => user.id, 'id', 'u1')
          .having(
            (user) => user.photoUrl,
            'photoUrl',
            'https://example.com/a.png',
          ),
    );
  });

  test('fetchCurrentUser maps GET /v1/users/me', () async {
    final adapter = _FakeAdapter()
      ..responseData = {
        'id': 'u1',
        'name': 'Ada',
        'email': 'ada@example.com',
        'avatarUrl': null,
      };
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter;
    final service = AuthApiService(dio: dio);

    final user = await service.fetchCurrentUser();

    expect(adapter.lastOptions?.path, '/v1/users/me');
    expect(user.photoUrl, isNull);
  });

  test('logout posts to /v1/auth/logout', () async {
    final adapter = _FakeAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter;
    final service = AuthApiService(dio: dio);

    await service.logout();

    expect(adapter.lastOptions?.path, '/v1/auth/logout');
    expect(adapter.lastOptions?.method, 'POST');
  });
}
