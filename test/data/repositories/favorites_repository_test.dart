import 'package:car_faults_app/data/repositories/favorites_repository.dart';
import 'package:car_faults_app/data/services/activity_logs_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeActivityLogsApiService extends ActivityLogsApiService {
  _FakeActivityLogsApiService({
    this.statusResponse,
    this.listResponse,
    this.error,
  }) : super(dio: Dio());

  final Map<String, dynamic>? statusResponse;
  final Map<String, dynamic>? listResponse;
  final DioException? error;

  String? lastType;
  String? lastResourceId;
  int? lastYear;
  String? lastStatusVehicleModelId;
  int? lastStatusYear;
  String? lastUnfavoriteVehicleModelId;
  int? lastUnfavoriteYear;

  @override
  Future<Map<String, dynamic>> create({
    required String type,
    required String resourceId,
    int? year,
  }) async {
    lastType = type;
    lastResourceId = resourceId;
    lastYear = year;
    if (error != null) throw error!;
    return {'id': 'log-1', 'type': type, 'resourceId': resourceId};
  }

  @override
  Future<Map<String, dynamic>> getFavoriteStatus({
    required String vehicleModelId,
    required int year,
  }) async {
    lastStatusVehicleModelId = vehicleModelId;
    lastStatusYear = year;
    if (error != null) throw error!;
    return statusResponse!;
  }

  @override
  Future<void> unfavorite({
    required String vehicleModelId,
    required int year,
  }) async {
    lastUnfavoriteVehicleModelId = vehicleModelId;
    lastUnfavoriteYear = year;
    if (error != null) throw error!;
  }

  @override
  Future<Map<String, dynamic>> listFavorites({int? limit}) async {
    if (error != null) throw error!;
    return listResponse!;
  }
}

DioException _dioError() {
  return DioException(
    requestOptions: RequestOptions(path: '/v1/activity-logs/favorites'),
    type: DioExceptionType.connectionError,
  );
}

const _favoriteJson = {
  'id': 'log-1',
  'vehicleModelId': 'vm-1',
  'year': 2001,
  'brand': 'Fiat',
  'model': 'Punto',
  'engine': '1.2',
  'fuelType': 'gasoline',
  'doors': 3,
  'imageUrl': null,
};

void main() {
  group('fetchStatus', () {
    test('returns the favorited flag from the API', () async {
      final api = _FakeActivityLogsApiService(
        statusResponse: {'vehicleModelId': 'vm-1', 'favorited': true},
      );
      final repository = FavoritesRepository(apiService: api);

      final favorited = await repository.fetchStatus(
        vehicleModelId: 'vm-1',
        year: 2001,
      );

      expect(api.lastStatusVehicleModelId, 'vm-1');
      expect(api.lastStatusYear, 2001);
      expect(favorited, isTrue);
    });

    test('treats a DioException as not favorited', () async {
      final repository = FavoritesRepository(
        apiService: _FakeActivityLogsApiService(error: _dioError()),
      );

      final favorited = await repository.fetchStatus(
        vehicleModelId: 'vm-1',
        year: 2001,
      );

      expect(favorited, isFalse);
    });
  });

  group('favorite', () {
    test('posts a vehicle_favorite activity log and returns true', () async {
      final api = _FakeActivityLogsApiService();
      final repository = FavoritesRepository(apiService: api);

      final result = await repository.favorite(
        vehicleModelId: 'vm-1',
        year: 2001,
      );

      expect(api.lastType, 'vehicle_favorite');
      expect(api.lastResourceId, 'vm-1');
      expect(api.lastYear, 2001);
      expect(result, isTrue);
    });

    test('returns false on a DioException', () async {
      final repository = FavoritesRepository(
        apiService: _FakeActivityLogsApiService(error: _dioError()),
      );

      final result = await repository.favorite(
        vehicleModelId: 'vm-1',
        year: 2001,
      );

      expect(result, isFalse);
    });
  });

  group('unfavorite', () {
    test('deletes the favorite and returns true', () async {
      final api = _FakeActivityLogsApiService();
      final repository = FavoritesRepository(apiService: api);

      final result = await repository.unfavorite(
        vehicleModelId: 'vm-1',
        year: 2001,
      );

      expect(api.lastUnfavoriteVehicleModelId, 'vm-1');
      expect(api.lastUnfavoriteYear, 2001);
      expect(result, isTrue);
    });

    test('returns false on a DioException', () async {
      final repository = FavoritesRepository(
        apiService: _FakeActivityLogsApiService(error: _dioError()),
      );

      final result = await repository.unfavorite(
        vehicleModelId: 'vm-1',
        year: 2001,
      );

      expect(result, isFalse);
    });
  });

  group('fetchFavorites', () {
    test('maps the first page of GET /v1/activity-logs/favorites', () async {
      final repository = FavoritesRepository(
        apiService: _FakeActivityLogsApiService(
          listResponse: {
            'items': [_favoriteJson],
            'nextCursor': null,
          },
        ),
      );

      final favorites = await repository.fetchFavorites();

      expect(favorites, hasLength(1));
      expect(favorites!.single.vehicleModelId, 'vm-1');
      expect(favorites.single.brand, 'Fiat');
    });

    test('returns null on a DioException', () async {
      final repository = FavoritesRepository(
        apiService: _FakeActivityLogsApiService(error: _dioError()),
      );

      expect(await repository.fetchFavorites(), isNull);
    });
  });
}
