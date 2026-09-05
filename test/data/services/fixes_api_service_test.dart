import 'dart:convert';
import 'dart:typed_data';

import 'package:car_faults_app/data/services/fixes_api_service.dart';
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
  test('vote posts the value to /v1/fixes/:id/vote', () async {
    final adapter = _FakeAdapter()..responseData = {'id': 'fix-1', 'likes': 13};
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter;
    final service = FixesApiService(dio: dio);

    final data = await service.vote(fixId: 'fix-1', value: 'like');

    expect(adapter.lastOptions?.path, '/v1/fixes/fix-1/vote');
    expect(adapter.lastOptions?.method, 'POST');
    expect(adapter.body, {'value': 'like'});
    expect(data['likes'], 13);
  });

  test('removeVote calls DELETE /v1/fixes/:id/vote', () async {
    final adapter = _FakeAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter;
    final service = FixesApiService(dio: dio);

    await service.removeVote(fixId: 'fix-1');

    expect(adapter.lastOptions?.path, '/v1/fixes/fix-1/vote');
    expect(adapter.lastOptions?.method, 'DELETE');
  });
}
