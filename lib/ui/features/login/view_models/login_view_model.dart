import 'package:flutter/foundation.dart';

import '../../../../data/repositories/auth_repository.dart';

/// Owns the Google command shared by the access button and the sign-up
/// prompt: both trigger the same OAuth flow, since Google decides whether
/// the account already exists.
class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required this.authRepository});

  final AuthRepository authRepository;

  bool _isSigningIn = false;
  bool get isSigningIn => _isSigningIn;

  AuthResult? _lastResult;
  AuthResult? get lastResult => _lastResult;

  Future<void> continueWithGoogle() async {
    if (_isSigningIn) return;

    _isSigningIn = true;
    _lastResult = null;
    notifyListeners();

    final result = await authRepository.signInWithGoogle();

    _isSigningIn = false;
    _lastResult = result;
    notifyListeners();
  }

  /// Clears [lastResult] once the View has shown it, so a rebuild doesn't
  /// show the same SnackBar again.
  void acknowledgeResult() {
    _lastResult = null;
  }
}
