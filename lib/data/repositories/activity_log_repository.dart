import 'package:dio/dio.dart';

import '../services/activity_logs_api_service.dart';
import '../services/api_client.dart';
import '../services/secure_token_storage.dart';

const _defectConsultedType = 'defect_consulted';

/// Records user activity via `car-faults-api`'s `/v1/activity-logs`
/// endpoint. JWT required — a call made while signed out fails silently,
/// since this is best-effort telemetry rather than a user-facing action.
///
/// Every parameter can be overridden — tests subclass [ActivityLogRepository]
/// and override individual methods instead of injecting fakes here, but the
/// seam is kept for callers that do want to swap a dependency.
class ActivityLogRepository {
  ActivityLogRepository({
    ActivityLogsApiService? apiService,
    SecureTokenStorage? tokenStorage,
  }) : _apiService =
           apiService ??
           ActivityLogsApiService(
             dio: buildApiDio(
               tokenStorage: tokenStorage ?? SecureTokenStorage(),
             ),
           );

  final ActivityLogsApiService _apiService;

  /// `POST /v1/activity-logs` with `type: 'defect_consulted'`, fired when
  /// the signed-in user opens a known issue's detail. Returns `true` on
  /// success; failures (including being signed out) are swallowed.
  Future<bool> recordDefectConsulted(String knownIssueId) async {
    try {
      await _apiService.create(
        type: _defectConsultedType,
        resourceId: knownIssueId,
      );
      return true;
    } on DioException {
      return false;
    }
  }
}
