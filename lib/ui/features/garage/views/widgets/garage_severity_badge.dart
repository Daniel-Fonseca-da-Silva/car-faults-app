import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Compact severity pill for the garage's known-issues list.
///
/// Unlike the lookup screen's severity badge, `high`/`critical` render as a
/// solid fill while `medium`/`low` render as an outline, matching the
/// garage reference.
class GarageSeverityBadge extends StatelessWidget {
  const GarageSeverityBadge({super.key, required this.severity});

  final IssueSeverity severity;

  static const _borderRadius = 6.0;
  static const _borderWidth = 1.5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _colorFor(severity);
    final isFilled =
        severity == IssueSeverity.high || severity == IssueSeverity.critical;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFilled ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(_borderRadius),
        border: isFilled ? null : Border.all(color: color, width: _borderWidth),
      ),
      child: Text(
        _labelFor(l10n, severity),
        style: TextStyle(
          color: isFilled ? AppColors.background : color,
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
        return AppColors.primary;
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
