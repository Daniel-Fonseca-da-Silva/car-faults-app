import 'dart:convert';
import 'dart:typed_data';

import 'package:car_faults_app/data/services/api_client.dart';
import 'package:car_faults_app/data/services/secure_token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTokenStorage extends SecureTokenStorage {
  _FakeTokenStorage([this.token]);

  String? token;
  var deleteCalls = 0;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> saveToken(String value) async {
    token = value;
  }

  @override
  Future<void> deleteToken() async {
    deleteCalls++;
    token = null;
  }
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({required this.statusCode});

  final int statusCode;
  RequestOptions? lastOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    return ResponseBody.fromString(
      jsonEncode({'ok': true}),
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
  test('attaches the mobile client header and bearer token', () async {
    final storage = _FakeTokenStorage('jwt-123');
    final adapter = _FakeAdapter(statusCode: 200);
    final dio = buildApiDio(tokenStorage: storage)..httpClientAdapter = adapter;

    await dio.get<Map<String, dynamic>>('/v1/users/me');

    expect(adapter.lastOptions?.headers[xClientHeader], xClientMobile);
    expect(adapter.lastOptions?.headers['Authorization'], 'Bearer jwt-123');
  });

  test('skips Authorization when no token is stored', () async {
    final storage = _FakeTokenStorage();
    final adapter = _FakeAdapter(statusCode: 200);
    final dio = buildApiDio(tokenStorage: storage)..httpClientAdapter = adapter;

    await dio.get<Map<String, dynamic>>('/v1/platform/stats');

    expect(adapter.lastOptions?.headers.containsKey('Authorization'), isFalse);
  });

  test('clears the token and notifies on 401', () async {
    final storage = _FakeTokenStorage('jwt-123');
    final adapter = _FakeAdapter(statusCode: 401);
    var unauthorizedCalls = 0;
    final dio = buildApiDio(
      tokenStorage: storage,
      onUnauthorized: () => unauthorizedCalls++,
    )..httpClientAdapter = adapter;

    await expectLater(
      dio.get<Map<String, dynamic>>('/v1/users/me'),
      throwsA(isA<DioException>()),
    );

    expect(storage.token, isNull);
    expect(storage.deleteCalls, 1);
    expect(unauthorizedCalls, 1);
  });
}
