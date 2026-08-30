/// Google Cloud OAuth configuration required for native Google Sign-In.
///
/// Android does not need [serverClientId] to complete the on-device sign-in
/// itself — the native SDK resolves this app's OAuth client from the
/// package name and SHA-1 certificate fingerprint registered in Google
/// Cloud Console. [serverClientId] is still required to obtain an `idToken`
/// whose audience `car-faults-api` can verify.
///
/// TODO(setup): before Google Sign-In can work end to end, someone with
/// access to the Google Cloud project must:
/// 1. Create an OAuth 2.0 "Android" client in Google Cloud Console using
///    this app's `applicationId` (see android/app/build.gradle.kts) and its
///    debug/release SHA-1 fingerprints (`./gradlew signingReport` from
///    android/).
/// 2. Create an OAuth 2.0 "Web application" client (no redirect URI needed)
///    and pass its client ID as [serverClientId] via
///    `--dart-define=GOOGLE_SERVER_CLIENT_ID=<id>.apps.googleusercontent.com`
///    at build/run time. `car-faults-api` must verify Google ID tokens
///    against this same client ID.
abstract final class GoogleAuthConfig {
  static const serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );
}
