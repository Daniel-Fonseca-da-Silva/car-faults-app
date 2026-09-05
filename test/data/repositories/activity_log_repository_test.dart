import 'package:car_faults_app/data/repositories/activity_log_repository.dart';
import 'package:car_faults_app/data/services/activity_logs_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeActivityLogsApiService extends ActivityLogsApiService {
  _FakeActivityLogsApiService({this.error}) : super(dio: Dio());

  final DioException? error;

  String? lastType;
  String? lastResourceId;

  @override
  Future<Map<String, dynamic>> create({
    required String type,
    required String resourceId,
    int? year,
  }) async {
    lastType = type;
    lastResourceId = resourceId;
    if (error != null) throw error!;
    return {'id': 'log-1', 'type': type, 'resourceId': resourceId};
  }
}

DioException _dioError() {
  return DioException(
    requestOptions: RequestOptions(path: '/v1/activity-logs'),
    type: DioExceptionType.connectionError,
  );
}

void main() {
  group('recordDefectConsulted', () {
    test('posts a defect_consulted activity log and returns true', () async {
      final api = _FakeActivityLogsApiService();
      final repository = ActivityLogRepository(apiService: api);

      final result = await repository.recordDefectConsulted('issue-1');

      expect(api.lastType, 'defect_consulted');
      expect(api.lastResourceId, 'issue-1');
      expect(result, isTrue);
    });

    test('returns false on a DioException (e.g. signed out)', () async {
      final repository = ActivityLogRepository(
        apiService: _FakeActivityLogsApiService(error: _dioError()),
      );

      expect(await repository.recordDefectConsulted('issue-1'), isFalse);
    });
  });
}
