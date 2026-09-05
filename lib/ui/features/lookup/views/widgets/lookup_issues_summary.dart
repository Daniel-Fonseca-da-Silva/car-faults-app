import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../view_models/lookup_results_view_model.dart';

/// Warning card below [LookupTechSpecs] summarising how many known issues
/// were found for the vehicle, and how many are critical or high severity.
///
/// Counts are derived from [LookupResultsViewModel.issues].
class LookupIssuesSummary extends StatelessWidget {
  const LookupIssuesSummary({super.key});

  static const _borderRadius = 12.0;
  static const _padding = 16.0;
  static const _borderOpacity = 0.3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final issues = context.watch<LookupResultsViewModel>().issues;
    final total = issues.length;
    final critical = issues
        .where((issue) => issue.severity == IssueSeverity.critical)
        .length;
    final high = issues
        .where((issue) => issue.severity == IssueSeverity.high)
        .length;

    const mutedStyle = TextStyle(color: AppColors.muted, fontSize: 14);
    const highlightStyle = TextStyle(
      color: AppColors.primary,
      fontWeight: FontWeight.w700,
    );
    const criticalStyle = TextStyle(
      color: AppColors.critical,
      fontWeight: FontWeight.w700,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(_padding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: _borderOpacity),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: mutedStyle,
                  children: [
                    TextSpan(text: '${l10n.lookupSummaryPrefix} '),
                    TextSpan(
                      text: l10n.lookupSummaryKnownIssues(total),
                      style: highlightStyle,
                    ),
                    TextSpan(text: ' ${l10n.lookupSummaryMiddle} '),
                    TextSpan(
                      text: l10n.lookupSummaryCritical(critical),
                      style: criticalStyle,
                    ),
                    TextSpan(text: ' ${l10n.lookupSummaryAnd} '),
                    TextSpan(
                      text: l10n.lookupSummaryHigh(high),
                      style: highlightStyle,
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
