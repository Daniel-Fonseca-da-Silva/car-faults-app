import '../../domain/models/app_locale.dart';
import '../../domain/models/platform_stats.dart';
import '../../domain/models/top_fault.dart';
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
  }) : _apiService =
           apiService ??
           PlatformApiService(
             dio: buildApiDio(
               tokenStorage: tokenStorage ?? SecureTokenStorage(),
             ),
           );

  final PlatformApiService _apiService;

  Future<PlatformStats> getStats() async {
    final json = await _apiService.getStats();
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
    final json = await _apiService.getFaults(
      locale: apiLanguageFor(locale),
      limit: limit,
    );
    final items = json['items'] as List<dynamic>;
    return items
        .map((item) => _mapTopFault(item as Map<String, dynamic>))
        .toList();
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
    );
  }
}
