import 'package:flutter/foundation.dart';

import '../../../domain/models/user.dart';

/// Holds the signed-in [User], if any, so shared UI (the nav drawer) can
/// show the account's photo and name.
///
/// Google OAuth has no mobile-facing endpoint yet, so nothing in production
/// calls [setUser] today; it exists for the UI to be ready once that wiring
/// lands.
class AuthSessionViewModel extends ChangeNotifier {
  User? _user;

  User? get user => _user;
  bool get isSignedIn => _user != null;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void signOut() {
    _user = null;
    notifyListeners();
  }
}
