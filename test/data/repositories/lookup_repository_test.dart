import 'package:car_faults_app/data/repositories/lookup_repository.dart';
import 'package:car_faults_app/data/services/lookup_api_service.dart';
import 'package:car_faults_app/domain/models/app_locale.dart';
import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:car_faults_app/ui/features/home/home_search_options.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLookupApiService extends LookupApiService {
  _FakeLookupApiService({this.response, this.error}) : super(dio: Dio());

  final Map<String, dynamic>? response;
  final DioException? error;

  String? lastBrand;
  String? lastModel;
  int? lastYear;
  String? lastEngine;
  String? lastFuelType;
  int? lastDoors;
  String? lastLanguage;

  @override
  Future<Map<String, dynamic>> lookup({
    required String brand,
    required String model,
    required int year,
    required String engine,
    required String fuelType,
    int? doors,
    required String language,
  }) async {
    lastBrand = brand;
    lastModel = model;
    lastYear = year;
    lastEngine = engine;
    lastFuelType = fuelType;
    lastDoors = doors;
    lastLanguage = language;

    if (error != null) throw error!;
    return response!;
  }
}

DioException _dioError({int? statusCode}) {
  final requestOptions = RequestOptions(path: '/v1/lookups');
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

const _sampleResponse = {
  'vehicle': {
    'id': 'veh-1',
    'brand': 'Volkswagen',
    'model': 'Polo',
    'name': 'Polo 6N1',
    'yearFrom': 1996,
    'yearTo': 2000,
    'engine': '1.6',
    'doors': 3,
    'fuelType': 'gasoline',
    'techSpecs': {'power_hp': 75},
  },
  'knownIssues': [
    {
      'id': 'issue-1',
      'title': 'Timing belt',
      'description': 'Wear',
      'severity': 'high',
      'typicalKm': 90000,
      'sources': <String>[],
      'fixes': <Map<String, dynamic>>[],
    },
  ],
};

void main() {
  test('search maps a successful API response', () async {
    final api = _FakeLookupApiService(response: _sampleResponse);
    final repository = LookupRepository(apiService: api);

    final result = await repository.search(
      brand: 'Volkswagen',
      model: 'Polo',
      year: 1996,
      engine: '1.6',
      fuel: FuelOption.petrol,
      doors: 3,
      locale: AppLocale.pt,
    );

    expect(api.lastFuelType, 'gasoline');
    expect(api.lastLanguage, 'pt-PT');
    expect(api.lastDoors, 3);

    expect(result, isA<LookupSearchSuccess>());
    final success = result as LookupSearchSuccess;
    expect(success.vehicle.brand, 'Volkswagen');
    expect(success.issues.single.severity, IssueSeverity.high);
  });

  test('search omits doors when null and maps locale en', () async {
    final api = _FakeLookupApiService(response: _sampleResponse);
    final repository = LookupRepository(apiService: api);

    await repository.search(
      brand: 'Fiat',
      model: 'Punto',
      year: 2005,
      engine: '1.2',
      fuel: FuelOption.diesel,
      locale: AppLocale.en,
    );

    expect(api.lastDoors, isNull);
    expect(api.lastFuelType, 'diesel');
    expect(api.lastLanguage, 'en-GB');
  });

  test('search maps Dio status codes to failure reasons', () async {
    Future<LookupFailureReason> reasonFor(int? status) async {
      final repository = LookupRepository(
        apiService: _FakeLookupApiService(error: _dioError(statusCode: status)),
      );
      final result = await repository.search(
        brand: 'A',
        model: 'B',
        year: 2000,
        engine: '1.0',
        fuel: FuelOption.petrol,
        locale: AppLocale.es,
      );
      return (result as LookupSearchFailure).reason;
    }

    expect(await reasonFor(null), LookupFailureReason.network);
    expect(await reasonFor(429), LookupFailureReason.rateLimited);
    expect(await reasonFor(503), LookupFailureReason.unavailable);
    expect(await reasonFor(404), LookupFailureReason.notFound);
    expect(await reasonFor(500), LookupFailureReason.unknown);
  });
}
