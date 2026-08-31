import 'dart:async';

import 'package:car_faults_app/data/repositories/auth_repository.dart';
import 'package:car_faults_app/ui/features/login/view_models/login_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Resolves [signInWithGoogle] immediately, without touching the real
/// Google Sign-In SDK or network, so [LoginViewModel] plumbing (loading
/// state, notifications, result handling) can be tested in isolation.
class _ImmediateAuthRepository extends AuthRepository {
  @override
  Future<AuthResult?> signInWithGoogle() async => const AuthComingSoon();
}

class _DelayedAuthRepository extends AuthRepository {
  final completer = Completer<AuthResult?>();
  var callCount = 0;

  @override
  Future<AuthResult?> signInWithGoogle() {
    callCount++;
    return completer.future;
  }
}

void main() {
  test('continueWithGoogle resolves via the injected repository', () async {
    final viewModel = LoginViewModel(
      authRepository: _ImmediateAuthRepository(),
    );

    await viewModel.continueWithGoogle();

    expect(viewModel.isSigningIn, isFalse);
    expect(viewModel.lastResult, const AuthComingSoon());
  });

  test(
    'continueWithGoogle sets isSigningIn while the call is in flight',
    () async {
      final repository = _DelayedAuthRepository();
      final viewModel = LoginViewModel(authRepository: repository);

      final future = viewModel.continueWithGoogle();

      expect(viewModel.isSigningIn, isTrue);
      expect(viewModel.lastResult, isNull);

      repository.completer.complete(const AuthComingSoon());
      await future;

      expect(viewModel.isSigningIn, isFalse);
      expect(viewModel.lastResult, const AuthComingSoon());
    },
  );

  test(
    'continueWithGoogle ignores a second tap while one is in flight',
    () async {
      final repository = _DelayedAuthRepository();
      final viewModel = LoginViewModel(authRepository: repository);

      final first = viewModel.continueWithGoogle();
      final second = viewModel.continueWithGoogle();

      repository.completer.complete(const AuthComingSoon());
      await first;
      await second;

      expect(repository.callCount, 1);
    },
  );

  test(
    'continueWithGoogle notifies listeners on start and on completion',
    () async {
      final viewModel = LoginViewModel(
        authRepository: _ImmediateAuthRepository(),
      );
      var notifications = 0;
      viewModel.addListener(() => notifications++);

      await viewModel.continueWithGoogle();

      expect(notifications, 2);
    },
  );

  test('acknowledgeResult clears lastResult without notifying', () async {
    final viewModel = LoginViewModel(
      authRepository: _ImmediateAuthRepository(),
    );
    await viewModel.continueWithGoogle();

    var notified = false;
    viewModel.addListener(() => notified = true);
    viewModel.acknowledgeResult();

    expect(viewModel.lastResult, isNull);
    expect(notified, isFalse);
  });
}
