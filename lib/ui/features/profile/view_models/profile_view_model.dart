import 'package:flutter/foundation.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/profile_repository.dart';
import '../../../../domain/models/profile_snapshot.dart';

/// Owns the profile snapshot loaded from [ProfileRepository] and the
/// account-deletion command triggered from the danger zone.
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({
    required this.authRepository,
    ProfileRepository? repository,
  }) : _repository = repository ?? ProfileRepository();

  final AuthRepository authRepository;
  final ProfileRepository _repository;

  ProfileSnapshot? _snapshot;
  ProfileSnapshot? get snapshot => _snapshot;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  DeleteAccountResult? _lastResult;
  DeleteAccountResult? get lastResult => _lastResult;

  /// `GET /v1/users/me` + `GET /v1/users/me/stats` + `GET /v1/user-vehicles`,
  /// combined by [ProfileRepository]. Keeps whatever [snapshot] is already
  /// shown on failure, so a background retry never blanks the screen.
  Future<void> load() async {
    if (_isLoading) return;

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    final snapshot = await _repository.fetchSnapshot();

    _isLoading = false;
    if (snapshot != null) {
      _snapshot = snapshot;
    } else {
      _hasError = true;
    }
    notifyListeners();
  }

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
