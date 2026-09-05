import 'dart:convert';
import 'dart:typed_data';

import 'package:car_faults_app/data/services/reviews_api_service.dart';
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
  test(
    'list calls GET /v1/reviews with the knownIssueId query param',
    () async {
      final adapter = _FakeAdapter()
        ..responseData = {'items': <dynamic>[], 'nextCursor': null};
      final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
        ..httpClientAdapter = adapter;
      final service = ReviewsApiService(dio: dio);

      final data = await service.list(knownIssueId: 'issue-1');

      expect(adapter.lastOptions?.path, '/v1/reviews');
      expect(adapter.lastOptions?.method, 'GET');
      expect(adapter.lastOptions?.queryParameters, {'knownIssueId': 'issue-1'});
      expect(data['items'], isEmpty);
    },
  );

  test('create posts the rating and comment', () async {
    final adapter = _FakeAdapter()
      ..responseData = {'id': 'review-1', 'rating': 4};
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter;
    final service = ReviewsApiService(dio: dio);

    final data = await service.create(
      knownIssueId: 'issue-1',
      rating: 4,
      comment: 'Fixed it myself',
    );

    expect(adapter.lastOptions?.path, '/v1/reviews');
    expect(adapter.lastOptions?.method, 'POST');
    expect(adapter.body, {
      'knownIssueId': 'issue-1',
      'rating': 4,
      'comment': 'Fixed it myself',
    });
    expect(data['id'], 'review-1');
  });

  test('create omits the comment field when null', () async {
    final adapter = _FakeAdapter()..responseData = const {'id': 'review-2'};
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter;
    final service = ReviewsApiService(dio: dio);

    await service.create(knownIssueId: 'issue-1', rating: 5);

    final body = adapter.body as Map<String, dynamic>;
    expect(body.containsKey('comment'), isFalse);
  });
}
