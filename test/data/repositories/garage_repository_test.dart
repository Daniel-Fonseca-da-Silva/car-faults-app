import 'package:car_faults_app/data/repositories/garage_repository.dart';
import 'package:car_faults_app/data/services/user_vehicles_api_service.dart';
import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUserVehiclesApiService extends UserVehiclesApiService {
  _FakeUserVehiclesApiService({
    this.listResponse,
    this.detailResponse,
    this.statusResponse,
    this.createResponse,
    this.error,
  }) : super(dio: Dio());

  final Map<String, dynamic>? listResponse;
  final Map<String, dynamic>? detailResponse;
  final Map<String, dynamic>? statusResponse;
  final Map<String, dynamic>? createResponse;
  final DioException? error;

  String? lastRemovedId;
  String? lastVehicleModelId;
  int? lastYear;

  @override
  Future<Map<String, dynamic>> list({
    String? language,
    String? cursor,
    int? limit,
  }) async {
    if (error != null) throw error!;
    return listResponse!;
  }

  @override
  Future<Map<String, dynamic>> getById(String id, {String? language}) async {
    if (error != null) throw error!;
    return detailResponse!;
  }

  @override
  Future<void> remove(String id) async {
    lastRemovedId = id;
    if (error != null) throw error!;
  }

  @override
  Future<Map<String, dynamic>> status({
    required String vehicleModelId,
    required int year,
  }) async {
    lastVehicleModelId = vehicleModelId;
    lastYear = year;
    if (error != null) throw error!;
    return statusResponse!;
  }

  @override
  Future<Map<String, dynamic>> create({
    required String vehicleModelId,
    required int year,
  }) async {
    lastVehicleModelId = vehicleModelId;
    lastYear = year;
    if (error != null) throw error!;
    return createResponse!;
  }
}

DioException _dioError({int? statusCode}) {
  final requestOptions = RequestOptions(path: '/v1/user-vehicles');
  return DioException(
    requestOptions: requestOptions,
    response: statusCode == null
        ? null
        : Response<dynamic>(
            requestOptions: requestOptions,
            statusCode: statusCode,
          ),
    type: statusCode == null
        ? DioExceptionType.connectionError
        : DioExceptionType.badResponse,
  );
}

const _vehicleJson = {
  'id': 'uv-1',
  'brand': 'Fiat',
  'model': 'Punto',
  'year': 2001,
  'engine': '1.2',
  'name': null,
  'knownIssuesCount': 1,
};

const _issueJson = {
  'id': 'issue-1',
  'title': 'Timing belt wear',
  'description': 'Wears out early.',
  'severity': 'high',
  'sources': <String>[],
  'fixes': <Map<String, dynamic>>[],
};

void main() {
  group('fetchVehicles', () {
    test('maps the first page of GET /v1/user-vehicles', () async {
      final repository = GarageRepository(
        apiService: _FakeUserVehiclesApiService(
          listResponse: {
            'items': [_vehicleJson],
            'nextCursor': null,
          },
        ),
      );

      final vehicles = await repository.fetchVehicles();

      expect(vehicles, hasLength(1));
      expect(vehicles!.single.id, 'uv-1');
      expect(vehicles.single.name, 'Fiat Punto');
    });

    test('returns null on a DioException', () async {
      final repository = GarageRepository(
        apiService: _FakeUserVehiclesApiService(error: _dioError()),
      );

      expect(await repository.fetchVehicles(), isNull);
    });
  });

  group('fetchKnownIssues', () {
    test('maps the knownIssues[] of GET /v1/user-vehicles/:id', () async {
      final repository = GarageRepository(
        apiService: _FakeUserVehiclesApiService(
          detailResponse: {
            ..._vehicleJson,
            'knownIssues': [_issueJson],
          },
        ),
      );

      final issues = await repository.fetchKnownIssues('uv-1');

      expect(issues, hasLength(1));
      expect(issues!.single.id, 'issue-1');
      expect(issues.single.severity, IssueSeverity.high);
    });

    test('returns null on a DioException', () async {
      final repository = GarageRepository(
        apiService: _FakeUserVehiclesApiService(error: _dioError()),
      );

      expect(await repository.fetchKnownIssues('uv-1'), isNull);
    });
  });

  group('removeVehicle', () {
    test('returns true on success', () async {
      final api = _FakeUserVehiclesApiService();
      final repository = GarageRepository(apiService: api);

      expect(await repository.removeVehicle('uv-1'), isTrue);
      expect(api.lastRemovedId, 'uv-1');
    });

    test('returns false on a DioException', () async {
      final repository = GarageRepository(
        apiService: _FakeUserVehiclesApiService(error: _dioError()),
      );

      expect(await repository.removeVehicle('uv-1'), isFalse);
    });
  });

  group('checkGarageStatus', () {
    test('returns the owned flag from GET /v1/user-vehicles/status', () async {
      final api = _FakeUserVehiclesApiService(
        statusResponse: {'vehicleModelId': 'vm-1', 'year': 2015, 'owned': true},
      );
      final repository = GarageRepository(apiService: api);

      final owned = await repository.checkGarageStatus(
        vehicleModelId: 'vm-1',
        year: 2015,
      );

      expect(api.lastVehicleModelId, 'vm-1');
      expect(api.lastYear, 2015);
      expect(owned, isTrue);
    });

    test('returns null on a DioException', () async {
      final repository = GarageRepository(
        apiService: _FakeUserVehiclesApiService(error: _dioError()),
      );

      final owned = await repository.checkGarageStatus(
        vehicleModelId: 'vm-1',
        year: 2015,
      );

      expect(owned, isNull);
    });
  });

  group('addVehicle', () {
    test('returns AddToGarageSuccess with the mapped vehicle', () async {
      final api = _FakeUserVehiclesApiService(createResponse: _vehicleJson);
      final repository = GarageRepository(apiService: api);

      final result = await repository.addVehicle(
        vehicleModelId: 'vm-1',
        year: 2001,
      );

      expect(api.lastVehicleModelId, 'vm-1');
      expect(api.lastYear, 2001);
      expect(result, isA<AddToGarageSuccess>());
      expect((result as AddToGarageSuccess).vehicle.id, 'uv-1');
    });

    test('maps a 409 response to AddToGarageDuplicate', () async {
      final repository = GarageRepository(
        apiService: _FakeUserVehiclesApiService(
          error: _dioError(statusCode: 409),
        ),
      );

      final result = await repository.addVehicle(
        vehicleModelId: 'vm-1',
        year: 2001,
      );

      expect(result, isA<AddToGarageDuplicate>());
    });

    test('maps other errors to AddToGarageFailure', () async {
      final repository = GarageRepository(
        apiService: _FakeUserVehiclesApiService(
          error: _dioError(statusCode: 500),
        ),
      );

      final result = await repository.addVehicle(
        vehicleModelId: 'vm-1',
        year: 2001,
      );

      expect(result, isA<AddToGarageFailure>());
    });
  });
}
