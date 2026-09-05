import 'dart:convert';
import 'dart:typed_data';

import 'package:car_faults_app/data/services/activity_logs_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdapter implements HttpClientAdapter {
  RequestOptions? lastOptions;
  Object? body;
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
  test('create posts the type and resourceId', () async {
    final adapter = _FakeAdapter()
      ..responseData = {
        'id': 'log-1',
        'type': 'defect_consulted',
        'resourceId': 'issue-1',
      };
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter;
    final service = ActivityLogsApiService(dio: dio);

    final data = await service.create(
      type: 'defect_consulted',
      resourceId: 'issue-1',
    );

    expect(adapter.lastOptions?.path, '/v1/activity-logs');
    expect(adapter.lastOptions?.method, 'POST');
    expect(adapter.body, {'type': 'defect_consulted', 'resourceId': 'issue-1'});
    expect(data['id'], 'log-1');
  });

  test('create includes year when given (vehicle_favorite)', () async {
    final adapter = _FakeAdapter()..responseData = const {'id': 'log-2'};
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter;
    final service = ActivityLogsApiService(dio: dio);

    await service.create(
      type: 'vehicle_favorite',
      resourceId: 'vm-1',
      year: 2015,
    );

    expect(adapter.body, {
      'type': 'vehicle_favorite',
      'resourceId': 'vm-1',
      'year': 2015,
    });
  });
}
