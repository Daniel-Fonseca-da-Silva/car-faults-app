import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:car_faults_app/data/services/storage_api_service.dart';
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
  test('uploadCommentImage posts a multipart file to POST /v1/storage/'
      'comment-images', () async {
    final tempFile = File('${Directory.systemTemp.path}/comment_image_test.jpg')
      ..writeAsBytesSync([0xff, 0xd8, 0xff]);
    addTearDown(() {
      if (tempFile.existsSync()) tempFile.deleteSync();
    });

    final adapter = _FakeAdapter()
      ..responseData = {
        'url': 'https://cdn.example.test/comments/user-1/photo.jpg',
      };
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'))
      ..httpClientAdapter = adapter;
    final service = StorageApiService(dio: dio);

    final data = await service.uploadCommentImage(tempFile.path);

    expect(adapter.lastOptions?.path, '/v1/storage/comment-images');
    expect(adapter.lastOptions?.method, 'POST');
    final sentData = adapter.lastOptions?.data;
    expect(sentData, isA<FormData>());
    expect((sentData as FormData).files.single.key, 'file');
    expect(data['url'], 'https://cdn.example.test/comments/user-1/photo.jpg');
  });
}
