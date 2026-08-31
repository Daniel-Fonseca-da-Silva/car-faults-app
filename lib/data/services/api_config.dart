/// Network configuration for `car-faults-api`.
abstract final class ApiConfig {
  /// Base URL of `car-faults-api`.
  ///
  /// Override via `--dart-define-from-file=env/dev.json` (see `env/dev.example.json`)
  /// or `--dart-define=API_BASE_URL=https://...`. The default targets the Android
  /// emulator's alias for the host machine's loopback address.
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );
}
