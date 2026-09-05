/// Google Cloud OAuth configuration required for native Google Sign-In.
///
/// Android does not need [serverClientId] to complete the on-device sign-in
/// itself — the native SDK resolves this app's OAuth client from the
/// package name and SHA-1 certificate fingerprint registered in Google
/// Cloud Console. [serverClientId] is still required to obtain an `idToken`
/// whose audience `car-faults-api` can verify (same value as
/// `GOOGLE_CLIENT_ID` in the API; set via `env/dev.json`).
abstract final class GoogleAuthConfig {
  static const serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );
}
