import 'dart:convert';
import 'dart:typed_data';

import 'package:car_faults_app/data/services/users_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdapter implements HttpClientAdapter {
  RequestOptions? lastOptions;
  Map<String, dynamic> responseData = const {};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    return ResponseBody.fromString(
      jsonEncode(responseData),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('getMe calls GET /v1/users/me', () async {
    final adapter = _FakeAdapter()..responseData = {'id': 'u1'};
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter;
    final service = UsersApiService(dio: dio);

    final data = await service.getMe();

    expect(adapter.lastOptions?.path, '/v1/users/me');
    expect(adapter.lastOptions?.method, 'GET');
    expect(data['id'], 'u1');
  });

  test('getStats calls GET /v1/users/me/stats', () async {
    final adapter = _FakeAdapter()..responseData = {'searchesCount': 5};
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter;
    final service = UsersApiService(dio: dio);

    final data = await service.getStats();

    expect(adapter.lastOptions?.path, '/v1/users/me/stats');
    expect(adapter.lastOptions?.method, 'GET');
    expect(data['searchesCount'], 5);
  });

  test('deleteMe calls DELETE /v1/users/me', () async {
    final adapter = _FakeAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter;
    final service = UsersApiService(dio: dio);

    await service.deleteMe();

    expect(adapter.lastOptions?.path, '/v1/users/me');
    expect(adapter.lastOptions?.method, 'DELETE');
  });
}
