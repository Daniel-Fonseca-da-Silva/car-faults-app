import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Pill badge showing a [KnownIssue]'s [IssueSeverity], color-coded per
/// [_colorFor].
class LookupSeverityBadge extends StatelessWidget {
  const LookupSeverityBadge({super.key, required this.severity});

  final IssueSeverity severity;

  static const _borderRadius = 6.0;
  static const _backgroundOpacity = 0.18;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _colorFor(severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: _backgroundOpacity),
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: Text(
        _labelFor(l10n, severity),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  static Color _colorFor(IssueSeverity severity) {
    switch (severity) {
      case IssueSeverity.low:
        return AppColors.success;
      case IssueSeverity.medium:
        return AppColors.warning;
      case IssueSeverity.high:
        return AppColors.primary;
      case IssueSeverity.critical:
        return AppColors.critical;
    }
  }

  static String _labelFor(AppLocalizations l10n, IssueSeverity severity) {
    switch (severity) {
      case IssueSeverity.low:
        return l10n.lookupSeverityLow;
      case IssueSeverity.medium:
        return l10n.lookupSeverityMedium;
      case IssueSeverity.high:
        return l10n.lookupSeverityHigh;
      case IssueSeverity.critical:
        return l10n.lookupSeverityCritical;
    }
  }
}
