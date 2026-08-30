import 'package:google_sign_in/google_sign_in.dart';

import 'google_auth_config.dart';

/// Thin wrapper around the native Google Sign-In SDK.
///
/// Returns the Google ID token that `POST /v1/auth/google/mobile` needs to
/// verify the account.
class GoogleAuthService {
  var _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    await GoogleSignIn.instance.initialize(
      serverClientId: GoogleAuthConfig.serverClientId.isEmpty
          ? null
          : GoogleAuthConfig.serverClientId,
    );
    _initialized = true;
  }

  /// Runs the interactive sign-in flow and returns the resulting ID token,
  /// or `null` if the user cancels.
  Future<String?> signIn() async {
    await _ensureInitialized();

    try {
      final account = await GoogleSignIn.instance.authenticate();
      return account.authentication.idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    await GoogleSignIn.instance.signOut();
  }
}
