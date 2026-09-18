import 'dart:convert';
import 'dart:typed_data';

import 'package:car_faults_app/data/services/reports_api_service.dart';
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
  test('create posts the contentType, contentId, reason and details', () async {
    final adapter = _FakeAdapter()..responseData = {'id': 'report-1'};
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter;
    final service = ReportsApiService(dio: dio);

    final data = await service.create(
      contentType: 'comment',
      contentId: 'comment-1',
      reason: 'spam',
      details: 'Repeated ad.',
    );

    expect(adapter.lastOptions?.path, '/v1/reports');
    expect(adapter.lastOptions?.method, 'POST');
    expect(adapter.body, {
      'contentType': 'comment',
      'contentId': 'comment-1',
      'reason': 'spam',
      'details': 'Repeated ad.',
    });
    expect(data['id'], 'report-1');
  });

  test('create omits the details field when null', () async {
    final adapter = _FakeAdapter()..responseData = const {'id': 'report-2'};
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter;
    final service = ReportsApiService(dio: dio);

    await service.create(
      contentType: 'review',
      contentId: 'review-1',
      reason: 'other',
    );

    final body = adapter.body as Map<String, dynamic>;
    expect(body.containsKey('details'), isFalse);
  });
}
