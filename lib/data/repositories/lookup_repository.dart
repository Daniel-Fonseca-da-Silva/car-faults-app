import 'package:dio/dio.dart';

import '../../domain/models/app_locale.dart';
import '../../domain/models/known_issue.dart';
import '../../domain/models/lookup_vehicle.dart';
import '../../ui/features/home/home_search_options.dart';
import '../mappers/locale_mapper.dart';
import '../mappers/lookup_mapper.dart';
import '../services/api_client.dart';
import '../services/lookup_api_service.dart';
import '../services/secure_token_storage.dart';

/// Outcome of a vehicle fault lookup.
sealed class LookupSearchResult {
  const LookupSearchResult();
}

class LookupSearchSuccess extends LookupSearchResult {
  const LookupSearchSuccess({required this.vehicle, required this.issues});

  final LookupVehicle vehicle;
  final List<KnownIssue> issues;
}

/// Why a lookup failed. Mirrors the HTTP statuses `GET /v1/lookups` can
/// return on its AI-generation path: 429 (mobile AI rate limit exceeded),
/// 503 (AI provider unavailable) and 404 (defensive — the query-based
/// lookup always resolves to a vehicle, generating one via AI if needed).
enum LookupFailureReason {
  rateLimited,
  unavailable,
  notFound,
  network,
  unknown,
}

class LookupSearchFailure extends LookupSearchResult {
  const LookupSearchFailure(this.reason);

  final LookupFailureReason reason;
}

/// Looks up known issues and tech specs for a vehicle via
/// `GET /v1/lookups`, anonymous or signed-in (the JWT is attached
/// automatically when present).
class LookupRepository {
  /// Every parameter can be overridden — tests subclass [LookupRepository]
  /// and override [search] instead of injecting fakes here, but the seam is
  /// kept for callers that do want to swap a dependency.
  LookupRepository({
    LookupApiService? apiService,
    SecureTokenStorage? tokenStorage,
  }) : _apiService =
           apiService ??
           LookupApiService(
             dio: buildApiDio(
               tokenStorage: tokenStorage ?? SecureTokenStorage(),
             ),
           );

  final LookupApiService _apiService;

  Future<LookupSearchResult> search({
    required String brand,
    required String model,
    required int year,
    required String engine,
    required FuelOption fuel,
    int? doors,
    required AppLocale locale,
  }) async {
    try {
      final json = await _apiService.lookup(
        brand: brand,
        model: model,
        year: year,
        engine: engine,
        fuelType: fuelTypeApiValue(fuel),
        doors: doors,
        language: apiLanguageFor(locale),
      );
      final mapped = mapLookupResponse(json);
      return LookupSearchSuccess(
        vehicle: mapped.vehicle,
        issues: mapped.issues,
      );
    } on DioException catch (e) {
      return LookupSearchFailure(_reasonFor(e));
    }
  }

  LookupFailureReason _reasonFor(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode == null) return LookupFailureReason.network;

    return switch (statusCode) {
      429 => LookupFailureReason.rateLimited,
      503 => LookupFailureReason.unavailable,
      404 => LookupFailureReason.notFound,
      _ => LookupFailureReason.unknown,
    };
  }
}
