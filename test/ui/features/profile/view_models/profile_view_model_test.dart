import 'dart:async';

import 'package:car_faults_app/data/repositories/auth_repository.dart';
import 'package:car_faults_app/ui/features/profile/profile_demo_display.dart';
import 'package:car_faults_app/ui/features/profile/view_models/profile_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _DelayedAuthRepository extends AuthRepository {
  final completer = Completer<AuthResult>();
  var callCount = 0;

  @override
  Future<AuthResult> deleteAccount() {
    callCount++;
    return completer.future;
  }
}

void main() {
  test('snapshot returns the demo profile snapshot', () {
    final viewModel = ProfileViewModel(authRepository: AuthRepository());

    expect(viewModel.snapshot, ProfileDemoDisplay.snapshot);
  });

  test(
    'deleteAccount resolves to comingSoon via the real repository',
    () async {
      final viewModel = ProfileViewModel(authRepository: AuthRepository());

      await viewModel.deleteAccount();

      expect(viewModel.isDeleting, isFalse);
      expect(viewModel.lastResult, AuthResult.comingSoon);
    },
  );

  test('deleteAccount sets isDeleting while the call is in flight', () async {
    final repository = _DelayedAuthRepository();
    final viewModel = ProfileViewModel(authRepository: repository);

    final future = viewModel.deleteAccount();

    expect(viewModel.isDeleting, isTrue);
    expect(viewModel.lastResult, isNull);

    repository.completer.complete(AuthResult.comingSoon);
    await future;

    expect(viewModel.isDeleting, isFalse);
    expect(viewModel.lastResult, AuthResult.comingSoon);
  });

  test('deleteAccount ignores a second call while one is in flight', () async {
    final repository = _DelayedAuthRepository();
    final viewModel = ProfileViewModel(authRepository: repository);

    final first = viewModel.deleteAccount();
    final second = viewModel.deleteAccount();

    repository.completer.complete(AuthResult.comingSoon);
    await first;
    await second;

    expect(repository.callCount, 1);
  });

  test('deleteAccount notifies listeners on start and on completion', () async {
    final viewModel = ProfileViewModel(authRepository: AuthRepository());
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    await viewModel.deleteAccount();

    expect(notifications, 2);
  });

  test('acknowledgeResult clears lastResult without notifying', () async {
    final viewModel = ProfileViewModel(authRepository: AuthRepository());
    await viewModel.deleteAccount();

    var notified = false;
    viewModel.addListener(() => notified = true);
    viewModel.acknowledgeResult();

    expect(viewModel.lastResult, isNull);
    expect(notified, isFalse);
  });
}
