import 'package:dio/dio.dart';

import '../../domain/models/app_locale.dart';
import '../../domain/models/platform_stats.dart';
import '../../domain/models/top_fault.dart';
import '../../domain/models/top_faults_page.dart';
import '../mappers/locale_mapper.dart';
import '../mappers/lookup_mapper.dart';
import '../services/api_client.dart';
import '../services/platform_api_service.dart';
import '../services/secure_token_storage.dart';

const _defaultFaultsLimit = 6;

/// Loads car-faults-api's public platform-wide stats and top faults for the
/// home screen. Both endpoints are public, so failures are surfaced as
/// plain exceptions — there is no per-status messaging to distinguish, unlike
/// the lookup repository's AI-generation path.
class PlatformRepository {
  PlatformRepository({
    PlatformApiService? apiService,
    SecureTokenStorage? tokenStorage,
    this.retryDelay = const Duration(seconds: 3),
  }) : _apiService =
           apiService ??
           PlatformApiService(
             dio: buildApiDio(
               tokenStorage: tokenStorage ?? SecureTokenStorage(),
             ),
           );

  final PlatformApiService _apiService;

  /// Overridable for tests, so they don't have to wait out a real delay.
  final Duration retryDelay;

  /// `car-faults-api` runs on Railway, which can idle the service after
  /// inactivity: the first request after a lull wakes it back up and often
  /// fails or times out while it boots, even though the exact same request
  /// then succeeds a moment later. One retry after a short delay smooths
  /// that over instead of surfacing an error the user has to retry by hand.
  Future<T> _withColdStartRetry<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException {
      await Future.delayed(retryDelay);
      return await request();
    }
  }

  Future<PlatformStats> getStats() async {
    final json = await _withColdStartRetry(_apiService.getStats);
    return PlatformStats(
      reportsCount: json['reportsCount'] as int,
      vehiclesCount: json['vehiclesCount'] as int,
      faultsCount: json['faultsCount'] as int,
    );
  }

  Future<List<TopFault>> getTopFaults({
    required AppLocale locale,
    int limit = _defaultFaultsLimit,
  }) async {
    final page = await getTopFaultsPage(locale: locale, limit: limit);
    return page.items;
  }

  /// Cursor-paginated version of [getTopFaults], for the full "Defeitos"
  /// list screen (the home teaser only ever needs the first page).
  Future<TopFaultsPage> getTopFaultsPage({
    required AppLocale locale,
    int limit = _defaultFaultsLimit,
    String? cursor,
  }) async {
    final json = await _withColdStartRetry(
      () => _apiService.getFaults(
        locale: apiLanguageFor(locale),
        limit: limit,
        cursor: cursor,
      ),
    );
    final items = json['items'] as List<dynamic>;
    return TopFaultsPage(
      items: items
          .map((item) => _mapTopFault(item as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
    );
  }

  TopFault _mapTopFault(Map<String, dynamic> json) {
    final vehicle = json['vehicle'] as Map<String, dynamic>;

    return TopFault(
      id: json['id'] as String,
      title: json['faultTitle'] as String,
      severity: issueSeverityFromApiValue(json['severity'] as String),
      reportCount: json['reportCount'] as int,
      vehicleBrand: vehicle['brand'] as String,
      vehicleModel: vehicle['model'] as String,
      vehicleYearFrom: vehicle['yearFrom'] as int,
      vehicleEngine: vehicle['engine'] as String?,
      vehicleFuelType: vehicle['fuelType'] as String?,
      vehicleDoors: vehicle['doors'] as int?,
    );
  }
}
