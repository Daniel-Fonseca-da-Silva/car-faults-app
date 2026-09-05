import 'dart:async';

import 'package:car_faults_app/data/repositories/auth_repository.dart';
import 'package:car_faults_app/data/repositories/profile_repository.dart';
import 'package:car_faults_app/domain/models/profile_snapshot.dart';
import 'package:car_faults_app/domain/models/saved_vehicle.dart';
import 'package:car_faults_app/domain/models/user.dart';
import 'package:car_faults_app/domain/models/user_stats.dart';
import 'package:car_faults_app/ui/features/profile/view_models/profile_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

final _snapshot = ProfileSnapshot(
  user: const User(id: 'u1', name: 'Ana Silva', email: 'ana@example.com'),
  createdAt: DateTime.utc(2026, 7, 17),
  updatedAt: DateTime.utc(2026, 7, 17),
  stats: const UserStats(
    searchesCount: 47,
    defectsConsultedCount: 128,
    savedVehiclesCount: 1,
    votesCount: 23,
  ),
  vehicles: const [
    SavedVehicle(
      id: 'vw-polo',
      brand: 'Volkswagen',
      model: 'Polo',
      name: 'Polo 6N1',
      yearFrom: 1994,
      yearTo: 1999,
      knownIssuesCount: 3,
    ),
  ],
);

class _FakeProfileRepository extends ProfileRepository {
  _FakeProfileRepository({this.snapshot});

  ProfileSnapshot? snapshot;
  var fetchSnapshotCalls = 0;

  @override
  Future<ProfileSnapshot?> fetchSnapshot() async {
    fetchSnapshotCalls++;
    return snapshot;
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
      );

      await viewModel.load();

      expect(viewModel.snapshot, _snapshot);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.hasError, isFalse);
    });

    test('sets hasError and leaves snapshot null on failure', () async {
      final viewModel = ProfileViewModel(
        authRepository: _ImmediateAuthRepository(),
        repository: _FakeProfileRepository(),
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
      );

      final first = viewModel.load();
      final second = viewModel.load();
      await first;
      await second;

      expect(repository.fetchSnapshotCalls, 1);
    });
  });

  group('deleteAccount', () {
    test('sets isDeleting while the call is in flight', () async {
      final repository = _DelayedAuthRepository();
      final viewModel = ProfileViewModel(
        authRepository: repository,
        repository: _FakeProfileRepository(),
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
      );

      await viewModel.deleteAccount();

      expect(viewModel.lastResult, const DeleteAccountFailure());
    });

    test('notifies listeners on start and on completion', () async {
      final viewModel = ProfileViewModel(
        authRepository: _ImmediateAuthRepository(),
        repository: _FakeProfileRepository(),
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
    );
    await viewModel.deleteAccount();

    var notified = false;
    viewModel.addListener(() => notified = true);
    viewModel.acknowledgeResult();

    expect(viewModel.lastResult, isNull);
    expect(notified, isFalse);
  });
}

class _FailingAuthRepository extends AuthRepository {
  @override
  Future<DeleteAccountResult> deleteAccount() async =>
      const DeleteAccountFailure();
}
