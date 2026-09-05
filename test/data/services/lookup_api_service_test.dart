import 'dart:convert';
import 'dart:typed_data';

import 'package:car_faults_app/data/services/lookup_api_service.dart';
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
  test('lookup calls GET /v1/lookups with the expected query params', () async {
    final adapter = _FakeAdapter()
      ..responseData = {
        'vehicle': {'id': '1'},
        'knownIssues': <dynamic>[],
      };
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter;
    final service = LookupApiService(dio: dio);

    final data = await service.lookup(
      brand: 'Volkswagen',
      model: 'Polo',
      year: 1996,
      engine: '1.6',
      fuelType: 'gasoline',
      doors: 3,
      language: 'pt-PT',
    );

    expect(adapter.lastOptions?.path, '/v1/lookups');
    expect(adapter.lastOptions?.method, 'GET');
    expect(adapter.lastOptions?.queryParameters, {
      'brand': 'Volkswagen',
      'model': 'Polo',
      'year': 1996,
      'engine': '1.6',
      'fuelType': 'gasoline',
      'doors': 3,
      'language': 'pt-PT',
    });
    expect(data['vehicle'], {'id': '1'});
  });

  test('lookup omits doors when null', () async {
    final adapter = _FakeAdapter()..responseData = const {};
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter;
    final service = LookupApiService(dio: dio);

    await service.lookup(
      brand: 'Fiat',
      model: 'Punto',
      year: 2005,
      engine: '1.2',
      fuelType: 'diesel',
      language: 'en-GB',
    );

    expect(adapter.lastOptions?.queryParameters.containsKey('doors'), isFalse);
  });
}
