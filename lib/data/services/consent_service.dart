import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Gathers GDPR ad consent (EEA/UK, which includes Portugal) via Google's
/// User Messaging Platform (UMP) SDK, bundled in `google_mobile_ads`.
///
/// Debug builds force EEA geography so the form can be exercised from any
/// device/location. To test on a physical device, run once, find the test
/// device id UMP logs to the console, and add it to [_testDeviceIds].
abstract final class ConsentService {
  static const _testDeviceIds = <String>[];

  /// Requests a consent info update and, if the user hasn't decided yet,
  /// loads and shows the consent form. Returns whether ads can now be
  /// requested — callers should only initialize the Mobile Ads SDK when
  /// this is `true`.
  static Future<bool> gatherConsent() async {
    final consentInfo = ConsentInformation.instance;
    final params = ConsentRequestParameters(
      consentDebugSettings: kDebugMode
          ? ConsentDebugSettings(
              debugGeography: DebugGeography.debugGeographyEea,
              testIdentifiers: _testDeviceIds,
            )
          : null,
    );

    final completer = Completer<void>();
    consentInfo.requestConsentInfoUpdate(
      params,
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((formError) {
          if (formError != null) {
            debugPrint('Consent form error: ${formError.message}');
          }
        });
        if (!completer.isCompleted) completer.complete();
      },
      (formError) {
        debugPrint('Consent info update failed: ${formError.message}');
        if (!completer.isCompleted) completer.complete();
      },
    );
    await completer.future;

    return consentInfo.canRequestAds();
  }

  /// Whether the app must offer a way to revisit ad consent choices (e.g. a
  /// "Ad consent" link), per the user's region.
  static Future<bool> isPrivacyOptionsRequired() async {
    final status = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    return status == PrivacyOptionsRequirementStatus.required;
  }

  /// Shows the privacy options form so the user can change their consent.
  static Future<void> showPrivacyOptionsForm() {
    return ConsentForm.showPrivacyOptionsForm((formError) {
      if (formError != null) {
        debugPrint('Privacy options form error: ${formError.message}');
      }
    });
  }
}
