import 'package:dio/dio.dart';

/// Talks to `car-faults-api`'s `/v1/storage` upload endpoints.
class StorageApiService {
  StorageApiService({required this.dio});

  final Dio dio;

  /// `POST /v1/storage/comment-images` — JWT required, multipart `file`
  /// (jpeg/png/webp, max 5 MB). Returns `{ url }` for the uploaded image.
  Future<Map<String, dynamic>> uploadCommentImage(String filePath) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/v1/storage/comment-images',
      data: FormData.fromMap({'file': await MultipartFile.fromFile(filePath)}),
    );
    return response.data!;
  }
}
