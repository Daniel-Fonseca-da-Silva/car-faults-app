import 'package:car_faults_app/data/repositories/profile_repository.dart';
import 'package:car_faults_app/data/services/user_vehicles_api_service.dart';
import 'package:car_faults_app/data/services/users_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUsersApiService extends UsersApiService {
  _FakeUsersApiService({this.meResponse, this.statsResponse, this.error})
    : super(dio: Dio());

  final Map<String, dynamic>? meResponse;
  final Map<String, dynamic>? statsResponse;
  final DioException? error;

  @override
  Future<Map<String, dynamic>> getMe() async {
    if (error != null) throw error!;
    return meResponse!;
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    if (error != null) throw error!;
    return statsResponse!;
  }
}

class _FakeUserVehiclesApiService extends UserVehiclesApiService {
  _FakeUserVehiclesApiService({this.listResponse, this.error})
    : super(dio: Dio());

  final Map<String, dynamic>? listResponse;
  final DioException? error;

  @override
  Future<Map<String, dynamic>> list({
    String? language,
    String? cursor,
    int? limit,
  }) async {
    if (error != null) throw error!;
    return listResponse!;
  }
}

DioException _dioError() {
  return DioException(
    requestOptions: RequestOptions(path: '/v1/users/me'),
    type: DioExceptionType.connectionError,
  );
}

const _userJson = {
  'id': 'u1',
  'name': 'Ana Silva',
  'email': 'ana@example.com',
  'avatarUrl': null,
  'createdAt': '2026-07-17T10:00:00.000Z',
  'updatedAt': '2026-07-18T10:00:00.000Z',
};

const _statsJson = {
  'searchesCount': 47,
  'defectsConsultedCount': 128,
  'savedVehiclesCount': 1,
  'votesCount': 23,
  'dislikesCount': 2,
  'favoritedVehiclesCount': 0,
};

const _vehicleJson = {
  'id': 'uv-1',
  'brand': 'Volkswagen',
  'model': 'Polo',
  'year': 2001,
  'engine': '1.0',
  'name': null,
  'knownIssuesCount': 3,
};

void main() {
  group('fetchSnapshot', () {
    test('combines the user, stats and first page of vehicles', () async {
      final repository = ProfileRepository(
        usersApiService: _FakeUsersApiService(
          meResponse: _userJson,
          statsResponse: _statsJson,
        ),
        userVehiclesApiService: _FakeUserVehiclesApiService(
          listResponse: {
            'items': [_vehicleJson],
            'nextCursor': null,
          },
        ),
      );

      final snapshot = await repository.fetchSnapshot();

      expect(snapshot, isNotNull);
      expect(snapshot!.user.id, 'u1');
      expect(snapshot.createdAt, DateTime.parse('2026-07-17T10:00:00.000Z'));
      expect(snapshot.updatedAt, DateTime.parse('2026-07-18T10:00:00.000Z'));
      expect(snapshot.stats.searchesCount, 47);
      expect(snapshot.stats.votesCount, 23);
      expect(snapshot.vehicles, hasLength(1));
      expect(snapshot.vehicles.single.id, 'uv-1');
      expect(snapshot.vehicles.single.name, 'Volkswagen Polo');
    });

    test('returns null when the user request fails', () async {
      final repository = ProfileRepository(
        usersApiService: _FakeUsersApiService(error: _dioError()),
        userVehiclesApiService: _FakeUserVehiclesApiService(
          listResponse: {'items': <dynamic>[]},
        ),
      );

      expect(await repository.fetchSnapshot(), isNull);
    });

    test('returns null when the vehicles request fails', () async {
      final repository = ProfileRepository(
        usersApiService: _FakeUsersApiService(
          meResponse: _userJson,
          statsResponse: _statsJson,
        ),
        userVehiclesApiService: _FakeUserVehiclesApiService(error: _dioError()),
      );

      expect(await repository.fetchSnapshot(), isNull);
    });
  });
}
