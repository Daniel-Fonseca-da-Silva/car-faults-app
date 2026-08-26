import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Uppercase muted label above a form input, with an optional `optional` badge.
class LabeledField extends StatelessWidget {
  const LabeledField({
    required this.label,
    required this.child,
    this.showOptionalBadge = false,
    super.key,
  });

  final String label;
  final Widget child;
  final bool showOptionalBadge;

  static const _labelFontSize = 11.0;
  static const _badgeFontSize = 10.0;
  static const _badgeRadius = 4.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [_labelRow(context), child],
    );
  }

  Widget _labelRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: _labelFontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        if (showOptionalBadge) _optionalBadge(context),
      ],
    );
  }

  Widget _optionalBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.muted.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(_badgeRadius),
      ),
      child: Text(
        AppLocalizations.of(context)!.homeSearchFieldOptional,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: _badgeFontSize,
        ),
      ),
    );
  }
}
