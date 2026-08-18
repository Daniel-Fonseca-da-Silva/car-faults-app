/// Outcome of a Google sign-in/sign-up attempt.
enum AuthResult { comingSoon }

/// Stub for the login screen's only auth command.
///
/// The API exposes Google OAuth solely as `GET /v1/auth/google`, which
/// redirects to the web app and drops a cookie there — there is no endpoint
/// a mobile client can call yet. Until one exists, this repository returns
/// an explicit [AuthResult] instead of making a network call, so the View
/// has something concrete to show the user.
class AuthRepository {
  Future<AuthResult> signInWithGoogle() async {
    return AuthResult.comingSoon;
  }
}
