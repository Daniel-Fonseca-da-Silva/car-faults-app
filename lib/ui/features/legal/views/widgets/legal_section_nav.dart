import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// In-page nav that jumps between the privacy policy and the terms document.
class LegalSectionNav extends StatelessWidget {
  const LegalSectionNav({
    super.key,
    required this.privacyLabel,
    required this.termsLabel,
    required this.onPrivacyTap,
    required this.onTermsTap,
  });

  final String privacyLabel;
  final String termsLabel;
  final VoidCallback onPrivacyTap;
  final VoidCallback onTermsTap;

  static const _minTouchHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surface)),
      ),
      child: Row(
        children: [
          Expanded(child: _navLink(privacyLabel, onPrivacyTap)),
          Expanded(child: _navLink(termsLabel, onTermsTap)),
        ],
      ),
    );
  }

  Widget _navLink(String label, VoidCallback onTap) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minTouchHeight),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
