import 'dart:io';

import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../data/services/consent_service.dart';
import '../theme/app_colors.dart';

/// Footer link that reopens the GDPR ad consent (UMP "privacy options")
/// form so EEA/UK users (incl. Portugal) can change their choice later.
///
/// Renders nothing on iOS (no ads there) or until the SDK confirms the
/// entry point is required for this user, per Google's UMP guidelines.
class AdPrivacyLink extends StatefulWidget {
  const AdPrivacyLink({super.key});

  @override
  State<AdPrivacyLink> createState() => _AdPrivacyLinkState();
}

class _AdPrivacyLinkState extends State<AdPrivacyLink> {
  static const _minTouchHeight = 48.0;

  var _isRequired = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      ConsentService.isPrivacyOptionsRequired().then((required) {
        if (!mounted || !required) return;
        setState(() => _isRequired = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRequired) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 24),
        Semantics(
          button: true,
          label: l10n.legalLinkAdConsent,
          child: InkWell(
            onTap: ConsentService.showPrivacyOptionsForm,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: _minTouchHeight),
              child: Center(
                child: Text(
                  l10n.legalLinkAdConsent,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
