import 'package:car_faults_app/domain/models/known_issue.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../lookup/views/lookup_results_view.dart';
import 'garage_issue_row.dart';

/// "Known issues" section of the garage screen: a compact list of the
/// selected vehicle's [KnownIssue]s with a link to the full lookup results.
///
/// Renders nothing when [issues] is empty (empty garage / no vehicle
/// selected).
class GarageKnownIssuesSection extends StatelessWidget {
  const GarageKnownIssuesSection({super.key, required this.issues});

  final List<KnownIssue> issues;

  static const _minTapTarget = 48.0;

  @override
  Widget build(BuildContext context) {
    if (issues.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.garageKnownIssuesTitle.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LookupResultsView()),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: _minTapTarget),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.garageViewDetails,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        for (var i = 0; i < issues.length; i++) ...[
          if (i > 0)
            Divider(color: AppColors.muted.withValues(alpha: 0.2), height: 1),
          GarageIssueRow(issue: issues[i]),
        ],
      ],
    );
  }
}
