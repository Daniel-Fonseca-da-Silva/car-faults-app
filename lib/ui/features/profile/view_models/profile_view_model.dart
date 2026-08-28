import 'package:flutter/foundation.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../domain/models/profile_snapshot.dart';
import '../profile_demo_display.dart';

/// Owns the profile snapshot and the account-deletion command triggered
/// from the danger zone.
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({required this.authRepository});

  final AuthRepository authRepository;

  ProfileSnapshot get snapshot => ProfileDemoDisplay.snapshot;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  AuthResult? _lastResult;
  AuthResult? get lastResult => _lastResult;

  Future<void> deleteAccount() async {
    if (_isDeleting) return;

    _isDeleting = true;
    _lastResult = null;
    notifyListeners();

    final result = await authRepository.deleteAccount();

    _isDeleting = false;
    _lastResult = result;
    notifyListeners();
  }

  /// Clears [lastResult] once the View has shown it, so a rebuild doesn't
  /// show the same SnackBar again.
  void acknowledgeResult() {
    _lastResult = null;
  }
}
