import 'package:car_faults_app/data/repositories/garage_repository.dart';
import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:car_faults_app/domain/models/known_issue.dart';
import 'package:car_faults_app/domain/models/saved_vehicle.dart';
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
);

const _otherVehicle = SavedVehicle(
  id: 'vw-polo',
  brand: 'Volkswagen',
  model: 'Polo',
  name: 'Polo',
  yearFrom: 1996,
  yearTo: 2000,
  knownIssuesCount: 1,
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
  var removeVehicleCalls = <String>[];

  @override
  Future<List<SavedVehicle>?> fetchVehicles() async => vehicles;

  @override
  Future<List<KnownIssue>?> fetchKnownIssues(String vehicleId) async {
    fetchKnownIssuesCalls.add(vehicleId);
    return issuesByVehicleId[vehicleId];
  }

  @override
  Future<bool> removeVehicle(String id) async {
    removeVehicleCalls.add(id);
    return removeSucceeds;
  }
}

void main() {
  group('load', () {
    test('loads one vehicle, selects it and loads its known issues', () async {
      final viewModel = GarageViewModel(
        repository: _FakeGarageRepository(vehicles: const [_vehicle]),
      );

      await viewModel.load();
      await Future<void>.value();
      await Future<void>.value();

      expect(viewModel.vehicles, hasLength(1));
      expect(viewModel.selectedVehicle?.id, 'fiat-punto-2001');
      expect(viewModel.issues, hasLength(1));
      expect(viewModel.issues.single.id, _issue.id);
    });

    test('empty vehicles: no selected vehicle and no issues', () async {
      final viewModel = GarageViewModel(
        repository: _FakeGarageRepository(vehicles: const []),
      );

      await viewModel.load();

      expect(viewModel.selectedVehicle, isNull);
      expect(viewModel.issues, isEmpty);
    });

    test('sets hasError when the vehicles request fails', () async {
      final viewModel = GarageViewModel(
        repository: _FakeGarageRepository(vehicles: null),
      );

      await viewModel.load();

      expect(viewModel.hasError, isTrue);
      expect(viewModel.vehicles, isEmpty);
    });

    test('ignores a second call while one is in flight', () async {
      final repository = _FakeGarageRepository(vehicles: const [_vehicle]);
      final viewModel = GarageViewModel(repository: repository);

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
      final viewModel = GarageViewModel(repository: repository);
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
      );
      await viewModel.load();
      await viewModel.removeVehicle('fiat-punto-2001');

      viewModel.acknowledgeRemoveFailure();

      expect(viewModel.removeFailed, isFalse);
    });

    test('notifies listeners', () async {
      final viewModel = GarageViewModel(
        repository: _FakeGarageRepository(vehicles: const [_vehicle]),
      );
      await viewModel.load();
      var notified = false;
      viewModel.addListener(() => notified = true);

      await viewModel.removeVehicle('fiat-punto-2001');

      expect(notified, isTrue);
    });
  });
}
