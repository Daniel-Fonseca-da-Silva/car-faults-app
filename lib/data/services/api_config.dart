/// Network configuration for `car-faults-api`.
abstract final class ApiConfig {
  /// Base URL of `car-faults-api`.
  ///
  /// TODO(setup): point this at the real API once it is deployed, via
  /// `--dart-define=API_BASE_URL=https://...`. The default targets the
  /// Android emulator's alias for the host machine's loopback address, so a
  /// local `car-faults-api` dev server (`npm run start:dev`) is reachable
  /// out of the box.
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );
}
