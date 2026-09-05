import 'dart:convert';
import 'dart:typed_data';

import 'package:car_faults_app/data/services/platform_api_service.dart';
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
  test('getStats calls GET /v1/platform/stats', () async {
    final adapter = _FakeAdapter()
      ..responseData = {
        'reportsCount': 1,
        'vehiclesCount': 2,
        'faultsCount': 3,
      };
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter;
    final service = PlatformApiService(dio: dio);

    final data = await service.getStats();

    expect(adapter.lastOptions?.path, '/v1/platform/stats');
    expect(adapter.lastOptions?.method, 'GET');
    expect(data['faultsCount'], 3);
  });

  test(
    'getFaults calls GET /v1/platform/faults with locale and limit',
    () async {
      final adapter = _FakeAdapter()..responseData = {'items': <dynamic>[]};
      final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
        ..httpClientAdapter = adapter;
      final service = PlatformApiService(dio: dio);

      final data = await service.getFaults(locale: 'es-ES', limit: 4);

      expect(adapter.lastOptions?.path, '/v1/platform/faults');
      expect(adapter.lastOptions?.queryParameters, {
        'locale': 'es-ES',
        'limit': 4,
      });
      expect(data['items'], isEmpty);
    },
  );
}
