import 'package:car_faults_app/data/repositories/platform_repository.dart';
import 'package:car_faults_app/data/services/platform_api_service.dart';
import 'package:car_faults_app/domain/models/app_locale.dart';
import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePlatformApiService extends PlatformApiService {
  _FakePlatformApiService({this.stats, this.faults}) : super(dio: Dio());

  final Map<String, dynamic>? stats;
  final Map<String, dynamic>? faults;

  String? lastLocale;
  int? lastLimit;

  @override
  Future<Map<String, dynamic>> getStats() async => stats!;

  @override
  Future<Map<String, dynamic>> getFaults({
    required String locale,
    required int limit,
  }) async {
    lastLocale = locale;
    lastLimit = limit;
    return faults!;
  }
}

void main() {
  test('getStats maps the platform stats JSON', () async {
    final repository = PlatformRepository(
      apiService: _FakePlatformApiService(
        stats: {'reportsCount': 34, 'vehiclesCount': 8, 'faultsCount': 120},
      ),
    );

    final stats = await repository.getStats();

    expect(stats.reportsCount, 34);
    expect(stats.vehiclesCount, 8);
    expect(stats.faultsCount, 120);
  });

  test(
    'getTopFaults maps items and forwards locale with default limit',
    () async {
      final api = _FakePlatformApiService(
        faults: {
          'items': [
            {
              'id': 'fault-1',
              'faultTitle': 'Oil leak',
              'severity': 'medium',
              'reportCount': 42,
              'vehicle': {'brand': 'BMW', 'model': '320d', 'yearFrom': 2012},
            },
          ],
        },
      );
      final repository = PlatformRepository(apiService: api);

      final faults = await repository.getTopFaults(locale: AppLocale.es);

      expect(api.lastLocale, 'es-ES');
      expect(api.lastLimit, 6);
      expect(faults, hasLength(1));
      expect(faults.single.id, 'fault-1');
      expect(faults.single.title, 'Oil leak');
      expect(faults.single.severity, IssueSeverity.medium);
      expect(faults.single.reportCount, 42);
      expect(faults.single.vehicleBrand, 'BMW');
      expect(faults.single.vehicleModel, '320d');
      expect(faults.single.vehicleYearFrom, 2012);
    },
  );

  test('getTopFaults forwards a custom limit', () async {
    final api = _FakePlatformApiService(faults: {'items': <dynamic>[]});
    final repository = PlatformRepository(apiService: api);

    final faults = await repository.getTopFaults(
      locale: AppLocale.pt,
      limit: 3,
    );

    expect(api.lastLocale, 'pt-PT');
    expect(api.lastLimit, 3);
    expect(faults, isEmpty);
  });
}
