import 'package:car_faults_app/data/repositories/platform_repository.dart';
import 'package:car_faults_app/data/services/platform_api_service.dart';
import 'package:car_faults_app/domain/models/app_locale.dart';
import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _fakeDioException(String path) {
  return DioException(requestOptions: RequestOptions(path: path));
}

class _FakePlatformApiService extends PlatformApiService {
  _FakePlatformApiService({this.stats, this.faults, this.failuresRemaining = 0})
    : super(dio: Dio());

  final Map<String, dynamic>? stats;
  final Map<String, dynamic>? faults;

  /// Number of calls (across both methods) that throw before succeeding.
  int failuresRemaining;

  String? lastLocale;
  int? lastLimit;
  String? lastCursor;
  var statsCalls = 0;
  var getFaultsCalls = 0;

  @override
  Future<Map<String, dynamic>> getStats() async {
    statsCalls++;
    if (failuresRemaining > 0) {
      failuresRemaining--;
      throw _fakeDioException('/v1/platform/stats');
    }
    return stats!;
  }

  @override
  Future<Map<String, dynamic>> getFaults({
    required String locale,
    required int limit,
    String? cursor,
  }) async {
    getFaultsCalls++;
    lastLocale = locale;
    lastLimit = limit;
    lastCursor = cursor;
    if (failuresRemaining > 0) {
      failuresRemaining--;
      throw _fakeDioException('/v1/platform/faults');
    }
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
              'contentLocale': 'es-ES',
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
      expect(faults.single.contentLocale, 'es-ES');
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

  test(
    'getTopFaultsPage maps vehicle engine/fuelType/doors and the next cursor',
    () async {
      final api = _FakePlatformApiService(
        faults: {
          'items': [
            {
              'id': 'fault-1',
              'faultTitle': 'Oil leak',
              'severity': 'medium',
              'reportCount': 42,
              'contentLocale': 'en-GB',
              'vehicle': {
                'brand': 'BMW',
                'model': '320d',
                'yearFrom': 2012,
                'engine': '2.0d',
                'fuelType': 'diesel',
                'doors': 4,
              },
            },
          ],
          'nextCursor': 'cursor-2',
        },
      );
      final repository = PlatformRepository(apiService: api);

      final page = await repository.getTopFaultsPage(
        locale: AppLocale.en,
        limit: 20,
        cursor: 'cursor-1',
      );

      expect(api.lastLocale, 'en-GB');
      expect(api.lastLimit, 20);
      expect(api.lastCursor, 'cursor-1');
      expect(page.nextCursor, 'cursor-2');
      expect(page.items, hasLength(1));
      expect(page.items.single.vehicleEngine, '2.0d');
      expect(page.items.single.vehicleFuelType, 'diesel');
      expect(page.items.single.vehicleDoors, 4);
    },
  );

  test('getTopFaultsPage exposes a null nextCursor on the last page', () async {
    final api = _FakePlatformApiService(
      faults: {'items': <dynamic>[], 'nextCursor': null},
    );
    final repository = PlatformRepository(apiService: api);

    final page = await repository.getTopFaultsPage(locale: AppLocale.pt);

    expect(page.nextCursor, isNull);
    expect(page.items, isEmpty);
  });

  group('cold-start retry', () {
    test('getStats retries once after a DioException and succeeds', () async {
      final api = _FakePlatformApiService(
        stats: {'reportsCount': 1, 'vehiclesCount': 2, 'faultsCount': 3},
        failuresRemaining: 1,
      );
      final repository = PlatformRepository(
        apiService: api,
        retryDelay: Duration.zero,
      );

      final stats = await repository.getStats();

      expect(stats.faultsCount, 3);
      expect(api.statsCalls, 2);
    });

    test('getStats gives up after the retry also fails', () async {
      final api = _FakePlatformApiService(failuresRemaining: 2);
      final repository = PlatformRepository(
        apiService: api,
        retryDelay: Duration.zero,
      );

      await expectLater(repository.getStats(), throwsA(isA<DioException>()));
      expect(api.statsCalls, 2);
    });

    test(
      'getTopFaultsPage retries once after a DioException and succeeds',
      () async {
        final api = _FakePlatformApiService(
          faults: {'items': <dynamic>[], 'nextCursor': null},
          failuresRemaining: 1,
        );
        final repository = PlatformRepository(
          apiService: api,
          retryDelay: Duration.zero,
        );

        final page = await repository.getTopFaultsPage(locale: AppLocale.pt);

        expect(page.items, isEmpty);
        expect(api.getFaultsCalls, 2);
      },
    );
  });
}
