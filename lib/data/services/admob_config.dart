import 'dart:io';

import 'package:flutter/foundation.dart';

/// AdMob configuration for the home banner.
///
/// The app ID lives in `AndroidManifest.xml` (the SDK reads it natively, not
/// from Dart) and must stay in sync with [appId] below. Override the real
/// unit id via `--dart-define-from-file=env/dev.json` (see
/// `env/dev.example.json`) or `--dart-define=ADMOB_HOME_BANNER_ID=...`.
abstract final class AdMobConfig {
  static const appId = String.fromEnvironment('ADMOB_APP_ID');

  static const homeBannerId = String.fromEnvironment('ADMOB_HOME_BANNER_ID');

  /// Google's official test banner unit, safe to load without a real ad
  /// account. See https://developers.google.com/admob/flutter/test-ads.
  static const _testHomeBannerId = 'ca-app-pub-3940256099942544/6300978111';

  /// The banner unit id to load: the test id in debug builds, the real
  /// configured id in release.
  static String get effectiveHomeBannerId =>
      kDebugMode ? _testHomeBannerId : homeBannerId;

  /// Whether GDPR ad consent (gathered via [ConsentService] at startup)
  /// allows ads to be requested. Defaults to `false` so no ad ever loads
  /// before consent has been resolved.
  static bool adsAllowed = false;

  /// Whether the home banner should be shown: Android only, ad consent
  /// resolved, and either running in debug (test ads always available) or
  /// a real unit id has been configured for release.
  static bool get isHomeBannerEnabled {
    if (!Platform.isAndroid) return false;
    if (!adsAllowed) return false;
    return kDebugMode || homeBannerId.isNotEmpty;
  }
}
