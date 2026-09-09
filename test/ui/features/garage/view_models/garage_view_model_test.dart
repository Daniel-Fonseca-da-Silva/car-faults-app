import 'dart:async';

import 'package:car_faults_app/data/repositories/garage_repository.dart';
import 'package:car_faults_app/data/repositories/lookup_repository.dart';
import 'package:car_faults_app/domain/models/app_locale.dart';
import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:car_faults_app/domain/models/known_issue.dart';
import 'package:car_faults_app/domain/models/lookup_vehicle.dart';
import 'package:car_faults_app/domain/models/saved_vehicle.dart';
import 'package:car_faults_app/ui/features/home/home_search_options.dart';
import 'package:car_faults_app/ui/features/garage/view_models/garage_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _vehicle = SavedVehicle(
  id: 'fiat-punto-2001',
  brand: 'Fiat',
  model: 'Punto',
  name: 'Punto',
  yearFrom: 2001,
  yearTo: 2001,
  knownIssuesCount: 3,
  engine: '1.2',
  fuelType: 'gasoline',
  doors: 3,
);

const _otherVehicle = SavedVehicle(
  id: 'vw-polo',
  brand: 'Volkswagen',
  model: 'Polo',
  name: 'Polo',
  yearFrom: 1996,
  yearTo: 2000,
  knownIssuesCount: 1,
  engine: '1.0',
);

const _issue = KnownIssue(
  id: 'timing-belt-wear',
  title: 'Timing belt wear and failure',
  description: 'Wears out early.',
  severity: IssueSeverity.high,
  sources: [],
  fixes: [],
  reviews: [],
);

const _lookupVehicle = LookupVehicle(
  id: 'vm-1',
  brand: 'Fiat',
  model: 'Punto',
  name: 'Punto',
  yearFrom: 2001,
  yearTo: 2001,
  engine: '1.2',
  doors: 3,
  fuelType: 'gasoline',
  powerHp: 60,
);

class _FakeGarageRepository extends GarageRepository {
  _FakeGarageRepository({
    this.vehicles,
    List<KnownIssue>? issues,
    this.removeSucceeds = true,
  }) : issuesByVehicleId = {
         if (vehicles != null && vehicles.isNotEmpty)
           vehicles.first.id: issues ?? const [_issue],
       };

  List<SavedVehicle>? vehicles;
  final Map<String, List<KnownIssue>> issuesByVehicleId;
  bool removeSucceeds;

  var fetchKnownIssuesCalls = <String>[];
  var fetchVehiclesLocales = <AppLocale>[];
  var fetchKnownIssuesLocales = <AppLocale>[];
  var removeVehicleCalls = <String>[];

  @override
  Future<List<SavedVehicle>?> fetchVehicles({required AppLocale locale}) async {
    fetchVehiclesLocales.add(locale);
    return vehicles;
  }

  @override
  Future<List<KnownIssue>?> fetchKnownIssues(
    String vehicleId, {
    required AppLocale locale,
  }) async {
    fetchKnownIssuesCalls.add(vehicleId);
    fetchKnownIssuesLocales.add(locale);
    return issuesByVehicleId[vehicleId];
  }

  @override
  Future<bool> removeVehicle(String id) async {
    removeVehicleCalls.add(id);
    return removeSucceeds;
  }
}

class _FakeLookupRepository extends LookupRepository {
  _FakeLookupRepository({this.result});

  LookupSearchResult? result;
  var searchCalls = <AppLocale>[];

  @override
  Future<LookupSearchResult> search({
    required String brand,
    required String model,
    required int year,
    required String engine,
    required FuelOption fuel,
    int? doors,
    required AppLocale locale,
  }) async {
    searchCalls.add(locale);
    return result ??
        const LookupSearchSuccess(vehicle: _lookupVehicle, issues: [_issue]);
  }
}

class _DelayedLookupRepository extends LookupRepository {
  _DelayedLookupRepository(this.completer);

  final Completer<LookupSearchResult> completer;

  @override
  Future<LookupSearchResult> search({
    required String brand,
    required String model,
    required int year,
    required String engine,
    required FuelOption fuel,
    int? doors,
    required AppLocale locale,
  }) => completer.future;
}

void main() {
  group('load', () {
    test('loads one vehicle, selects it and loads its known issues', () async {
      final viewModel = GarageViewModel(
        repository: _FakeGarageRepository(vehicles: const [_vehicle]),
        locale: AppLocale.pt,
      );

      await viewModel.load();
      await Future<void>.value();
      await Future<void>.value();

      expect(viewModel.vehicles, hasLength(1));
      expect(viewModel.selectedVehicle?.id, 'fiat-punto-2001');
      expect(viewModel.issues, hasLength(1));
      expect(viewModel.issues.single.id, _issue.id);
    });

    test('sends the ViewModel locale to both calls', () async {
      final repository = _FakeGarageRepository(vehicles: const [_vehicle]);
      final viewModel = GarageViewModel(
        repository: repository,
        locale: AppLocale.es,
      );

      await viewModel.load();
      await Future<void>.value();
      await Future<void>.value();

      expect(repository.fetchVehiclesLocales, [AppLocale.es]);
      expect(repository.fetchKnownIssuesLocales, [AppLocale.es]);
    });

    test('empty vehicles: no selected vehicle and no issues', () async {
      final viewModel = GarageViewModel(
        repository: _FakeGarageRepository(vehicles: const []),
        locale: AppLocale.pt,
      );

      await viewModel.load();

      expect(viewModel.selectedVehicle, isNull);
      expect(viewModel.issues, isEmpty);
    });

    test('sets hasError when the vehicles request fails', () async {
      final viewModel = GarageViewModel(
        repository: _FakeGarageRepository(vehicles: null),
        locale: AppLocale.pt,
      );

      await viewModel.load();

      expect(viewModel.hasError, isTrue);
      expect(viewModel.vehicles, isEmpty);
    });

    test('ignores a second call while one is in flight', () async {
      final repository = _FakeGarageRepository(vehicles: const [_vehicle]);
      final viewModel = GarageViewModel(
        repository: repository,
        locale: AppLocale.pt,
      );

      final first = viewModel.load();
      final second = viewModel.load();
      await first;
      await second;
      await Future<void>.value();
      await Future<void>.value();

      expect(repository.fetchKnownIssuesCalls, ['fiat-punto-2001']);
    });
  });

  group('removeVehicle', () {
    test('removes the only vehicle and clears the selection', () async {
      final viewModel = GarageViewModel(
        repository: _FakeGarageRepository(vehicles: const [_vehicle]),
        locale: AppLocale.pt,
      );
      await viewModel.load();
      await Future<void>.value();

      await viewModel.removeVehicle('fiat-punto-2001');

      expect(viewModel.vehicles, isEmpty);
      expect(viewModel.selectedVehicle, isNull);
      expect(viewModel.issues, isEmpty);
    });

    test('selects and loads issues for the next vehicle', () async {
      final repository = _FakeGarageRepository(
        vehicles: const [_vehicle, _otherVehicle],
      );
      repository.issuesByVehicleId[_otherVehicle.id] = const [];
      final viewModel = GarageViewModel(
        repository: repository,
        locale: AppLocale.pt,
      );
      await viewModel.load();
      await Future<void>.value();
      await Future<void>.value();

      await viewModel.removeVehicle('fiat-punto-2001');
      await Future<void>.value();
      await Future<void>.value();

      expect(viewModel.vehicles, hasLength(1));
      expect(viewModel.selectedVehicle?.id, _otherVehicle.id);
    });

    test('ignores an unknown id', () async {
      final viewModel = GarageViewModel(
        repository: _FakeGarageRepository(vehicles: const [_vehicle]),
        locale: AppLocale.pt,
      );
      await viewModel.load();

      await viewModel.removeVehicle('unknown-id');

      expect(viewModel.vehicles, hasLength(1));
    });

    test(
      'sets removeFailed and keeps the vehicle when the API call fails',
      () async {
        final viewModel = GarageViewModel(
          repository: _FakeGarageRepository(
            vehicles: const [_vehicle],
            removeSucceeds: false,
          ),
          locale: AppLocale.pt,
        );
        await viewModel.load();

        await viewModel.removeVehicle('fiat-punto-2001');

        expect(viewModel.removeFailed, isTrue);
        expect(viewModel.vehicles, hasLength(1));
      },
    );

    test('acknowledgeRemoveFailure clears removeFailed', () async {
      final viewModel = GarageViewModel(
        repository: _FakeGarageRepository(
          vehicles: const [_vehicle],
          removeSucceeds: false,
        ),
        locale: AppLocale.pt,
      );
      await viewModel.load();
      await viewModel.removeVehicle('fiat-punto-2001');

      viewModel.acknowledgeRemoveFailure();

      expect(viewModel.removeFailed, isFalse);
    });

    test('notifies listeners', () async {
      final viewModel = GarageViewModel(
        repository: _FakeGarageRepository(vehicles: const [_vehicle]),
        locale: AppLocale.pt,
      );
      await viewModel.load();
      var notified = false;
      viewModel.addListener(() => notified = true);

      await viewModel.removeVehicle('fiat-punto-2001');

      expect(notified, isTrue);
    });
  });

  group('openVehicle', () {
    test('looks up the vehicle with the ViewModel locale', () async {
      final lookupRepository = _FakeLookupRepository();
      final viewModel = GarageViewModel(
        repository: _FakeGarageRepository(),
        lookupRepository: lookupRepository,
        locale: AppLocale.pt,
      );

      await viewModel.openVehicle(_vehicle);

      expect(lookupRepository.searchCalls, [AppLocale.pt]);
      expect(viewModel.pendingSearchedYear, _vehicle.yearFrom);
      expect(viewModel.pendingResult, isA<LookupSearchSuccess>());
    });

    test(
      'isOpeningVehicle is true only while the lookup is in flight',
      () async {
        final completer = Completer<LookupSearchResult>();
        final viewModel = GarageViewModel(
          repository: _FakeGarageRepository(),
          lookupRepository: _DelayedLookupRepository(completer),
          locale: AppLocale.pt,
        );

        final future = viewModel.openVehicle(_vehicle);
        expect(viewModel.isOpeningVehicle(_vehicle.id), isTrue);

        completer.complete(
          const LookupSearchSuccess(vehicle: _lookupVehicle, issues: [_issue]),
        );
        await future;

        expect(viewModel.isOpeningVehicle(_vehicle.id), isFalse);
      },
    );

    test('ignores a second call while one is in flight', () async {
      final lookupRepository = _FakeLookupRepository();
      final viewModel = GarageViewModel(
        repository: _FakeGarageRepository(),
        lookupRepository: lookupRepository,
        locale: AppLocale.pt,
      );

      final first = viewModel.openVehicle(_vehicle);
      final second = viewModel.openVehicle(_vehicle);
      await first;
      await second;

      expect(lookupRepository.searchCalls, hasLength(1));
    });

    test('surfaces a lookup failure as pendingResult', () async {
      final viewModel = GarageViewModel(
        repository: _FakeGarageRepository(),
        lookupRepository: _FakeLookupRepository(
          result: const LookupSearchFailure(LookupFailureReason.notFound),
        ),
        locale: AppLocale.pt,
      );

      await viewModel.openVehicle(_vehicle);

      expect(
        viewModel.pendingResult,
        const LookupSearchFailure(LookupFailureReason.notFound),
      );
    });

    test('acknowledgePendingResult clears pendingResult', () async {
      final viewModel = GarageViewModel(
        repository: _FakeGarageRepository(),
        lookupRepository: _FakeLookupRepository(),
        locale: AppLocale.pt,
      );
      await viewModel.openVehicle(_vehicle);

      viewModel.acknowledgePendingResult();

      expect(viewModel.pendingResult, isNull);
    });
  });
}
