import 'dart:convert';
import 'dart:typed_data';

import 'package:car_faults_app/data/services/user_vehicles_api_service.dart';
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
  test(
    'list calls GET /v1/user-vehicles with the given query params',
    () async {
      final adapter = _FakeAdapter()..responseData = {'items': <dynamic>[]};
      final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
        ..httpClientAdapter = adapter;
      final service = UserVehiclesApiService(dio: dio);

      final data = await service.list(
        language: 'pt-PT',
        cursor: 'abc',
        limit: 10,
      );

      expect(adapter.lastOptions?.path, '/v1/user-vehicles');
      expect(adapter.lastOptions?.method, 'GET');
      expect(adapter.lastOptions?.queryParameters, {
        'language': 'pt-PT',
        'cursor': 'abc',
        'limit': 10,
      });
      expect(data['items'], isEmpty);
    },
  );

  test('list omits query params when absent', () async {
    final adapter = _FakeAdapter()..responseData = {'items': <dynamic>[]};
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter;
    final service = UserVehiclesApiService(dio: dio);

    await service.list();

    expect(adapter.lastOptions?.queryParameters, isEmpty);
  });

  test('getById calls GET /v1/user-vehicles/:id', () async {
    final adapter = _FakeAdapter()
      ..responseData = {'id': 'uv-1', 'knownIssues': <dynamic>[]};
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter;
    final service = UserVehiclesApiService(dio: dio);

    final data = await service.getById('uv-1', language: 'en-GB');

    expect(adapter.lastOptions?.path, '/v1/user-vehicles/uv-1');
    expect(adapter.lastOptions?.method, 'GET');
    expect(adapter.lastOptions?.queryParameters, {'language': 'en-GB'});
    expect(data['id'], 'uv-1');
  });

  test('remove calls DELETE /v1/user-vehicles/:id', () async {
    final adapter = _FakeAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter;
    final service = UserVehiclesApiService(dio: dio);

    await service.remove('uv-1');

    expect(adapter.lastOptions?.path, '/v1/user-vehicles/uv-1');
    expect(adapter.lastOptions?.method, 'DELETE');
  });
}
