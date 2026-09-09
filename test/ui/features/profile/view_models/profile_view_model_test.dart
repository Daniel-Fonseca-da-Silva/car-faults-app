import 'dart:async';

import 'package:car_faults_app/data/repositories/auth_repository.dart';
import 'package:car_faults_app/data/repositories/lookup_repository.dart';
import 'package:car_faults_app/data/repositories/profile_repository.dart';
import 'package:car_faults_app/domain/models/app_locale.dart';
import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:car_faults_app/domain/models/known_issue.dart';
import 'package:car_faults_app/domain/models/lookup_vehicle.dart';
import 'package:car_faults_app/domain/models/profile_snapshot.dart';
import 'package:car_faults_app/domain/models/saved_vehicle.dart';
import 'package:car_faults_app/domain/models/user.dart';
import 'package:car_faults_app/domain/models/user_stats.dart';
import 'package:car_faults_app/ui/features/home/home_search_options.dart';
import 'package:car_faults_app/ui/features/profile/view_models/profile_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _vehicle = SavedVehicle(
  id: 'vw-polo',
  brand: 'Volkswagen',
  model: 'Polo',
  name: 'Polo 6N1',
  yearFrom: 1994,
  yearTo: 1999,
  knownIssuesCount: 3,
  engine: '1.4',
  fuelType: 'gasoline',
  doors: 3,
);

final _snapshot = ProfileSnapshot(
  user: const User(id: 'u1', name: 'Ana Silva', email: 'ana@example.com'),
  createdAt: DateTime.utc(2026, 7, 17),
  updatedAt: DateTime.utc(2026, 7, 17),
  stats: const UserStats(
    searchesCount: 47,
    defectsConsultedCount: 128,
    savedVehiclesCount: 1,
    votesCount: 23,
    favoritedVehiclesCount: 9,
  ),
  vehicles: const [_vehicle],
);

const _lookupVehicle = LookupVehicle(
  id: 'vm-1',
  brand: 'Volkswagen',
  model: 'Polo',
  name: 'Polo 6N1',
  yearFrom: 1994,
  yearTo: 1999,
  engine: '1.4',
  doors: 3,
  fuelType: 'gasoline',
  powerHp: 60,
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

class _FakeProfileRepository extends ProfileRepository {
  _FakeProfileRepository({this.snapshot});

  ProfileSnapshot? snapshot;
  var fetchSnapshotCalls = <AppLocale>[];

  @override
  Future<ProfileSnapshot?> fetchSnapshot({required AppLocale locale}) async {
    fetchSnapshotCalls.add(locale);
    return snapshot;
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

class _DelayedAuthRepository extends AuthRepository {
  final completer = Completer<DeleteAccountResult>();
  var callCount = 0;

  @override
  Future<DeleteAccountResult> deleteAccount() {
    callCount++;
    return completer.future;
  }
}

class _ImmediateAuthRepository extends AuthRepository {
  @override
  Future<DeleteAccountResult> deleteAccount() async =>
      const DeleteAccountSuccess();
}

void main() {
  group('load', () {
    test('sets the snapshot on success', () async {
      final viewModel = ProfileViewModel(
        authRepository: _ImmediateAuthRepository(),
        repository: _FakeProfileRepository(snapshot: _snapshot),
        locale: AppLocale.pt,
      );

      await viewModel.load();

      expect(viewModel.snapshot, _snapshot);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.hasError, isFalse);
    });

    test('sends the ViewModel locale on every load', () async {
      final repository = _FakeProfileRepository(snapshot: _snapshot);
      final viewModel = ProfileViewModel(
        authRepository: _ImmediateAuthRepository(),
        repository: repository,
        locale: AppLocale.pt,
      );

      await viewModel.load();

      expect(repository.fetchSnapshotCalls, [AppLocale.pt]);
    });

    test('sets hasError and leaves snapshot null on failure', () async {
      final viewModel = ProfileViewModel(
        authRepository: _ImmediateAuthRepository(),
        repository: _FakeProfileRepository(),
        locale: AppLocale.pt,
      );

      await viewModel.load();

      expect(viewModel.snapshot, isNull);
      expect(viewModel.hasError, isTrue);
    });

    test('keeps the previous snapshot when a retry fails', () async {
      final repository = _FakeProfileRepository(snapshot: _snapshot);
      final viewModel = ProfileViewModel(
        authRepository: _ImmediateAuthRepository(),
        repository: repository,
        locale: AppLocale.pt,
      );

      await viewModel.load();
      repository.snapshot = null;
      await viewModel.load();

      expect(viewModel.snapshot, _snapshot);
      expect(viewModel.hasError, isTrue);
    });

    test('ignores a second call while one is in flight', () async {
      final repository = _FakeProfileRepository(snapshot: _snapshot);
      final viewModel = ProfileViewModel(
        authRepository: _ImmediateAuthRepository(),
        repository: repository,
        locale: AppLocale.pt,
      );

      final first = viewModel.load();
      final second = viewModel.load();
      await first;
      await second;

      expect(repository.fetchSnapshotCalls, hasLength(1));
    });
  });

  group('deleteAccount', () {
    test('sets isDeleting while the call is in flight', () async {
      final repository = _DelayedAuthRepository();
      final viewModel = ProfileViewModel(
        authRepository: repository,
        repository: _FakeProfileRepository(),
        locale: AppLocale.pt,
      );

      final future = viewModel.deleteAccount();

      expect(viewModel.isDeleting, isTrue);
      expect(viewModel.lastResult, isNull);

      repository.completer.complete(const DeleteAccountSuccess());
      await future;

      expect(viewModel.isDeleting, isFalse);
      expect(viewModel.lastResult, const DeleteAccountSuccess());
    });

    test('ignores a second call while one is in flight', () async {
      final repository = _DelayedAuthRepository();
      final viewModel = ProfileViewModel(
        authRepository: repository,
        repository: _FakeProfileRepository(),
        locale: AppLocale.pt,
      );

      final first = viewModel.deleteAccount();
      final second = viewModel.deleteAccount();

      repository.completer.complete(const DeleteAccountSuccess());
      await first;
      await second;

      expect(repository.callCount, 1);
    });

    test('resolves to DeleteAccountFailure on error', () async {
      final viewModel = ProfileViewModel(
        authRepository: _FailingAuthRepository(),
        repository: _FakeProfileRepository(),
        locale: AppLocale.pt,
      );

      await viewModel.deleteAccount();

      expect(viewModel.lastResult, const DeleteAccountFailure());
    });

    test('notifies listeners on start and on completion', () async {
      final viewModel = ProfileViewModel(
        authRepository: _ImmediateAuthRepository(),
        repository: _FakeProfileRepository(),
        locale: AppLocale.pt,
      );
      var notifications = 0;
      viewModel.addListener(() => notifications++);

      await viewModel.deleteAccount();

      expect(notifications, 2);
    });
  });

  test('acknowledgeResult clears lastResult without notifying', () async {
    final viewModel = ProfileViewModel(
      authRepository: _ImmediateAuthRepository(),
      repository: _FakeProfileRepository(),
      locale: AppLocale.pt,
    );
    await viewModel.deleteAccount();

    var notified = false;
    viewModel.addListener(() => notified = true);
    viewModel.acknowledgeResult();

    expect(viewModel.lastResult, isNull);
    expect(notified, isFalse);
  });

  group('openVehicle', () {
    test('looks up the vehicle with the ViewModel locale', () async {
      final lookupRepository = _FakeLookupRepository();
      final viewModel = ProfileViewModel(
        authRepository: _ImmediateAuthRepository(),
        repository: _FakeProfileRepository(),
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
        final viewModel = ProfileViewModel(
          authRepository: _ImmediateAuthRepository(),
          repository: _FakeProfileRepository(),
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
      final viewModel = ProfileViewModel(
        authRepository: _ImmediateAuthRepository(),
        repository: _FakeProfileRepository(),
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
      final viewModel = ProfileViewModel(
        authRepository: _ImmediateAuthRepository(),
        repository: _FakeProfileRepository(),
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
      final viewModel = ProfileViewModel(
        authRepository: _ImmediateAuthRepository(),
        repository: _FakeProfileRepository(),
        lookupRepository: _FakeLookupRepository(),
        locale: AppLocale.pt,
      );
      await viewModel.openVehicle(_vehicle);

      viewModel.acknowledgePendingResult();

      expect(viewModel.pendingResult, isNull);
    });
  });
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

class _FailingAuthRepository extends AuthRepository {
  @override
  Future<DeleteAccountResult> deleteAccount() async =>
      const DeleteAccountFailure();
}
