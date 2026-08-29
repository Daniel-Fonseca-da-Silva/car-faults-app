import 'package:car_faults_app/domain/models/known_issue.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'garage_severity_badge.dart';

/// One compact row in [GarageKnownIssuesSection]: title, severity badge,
/// description and sources — no accordion, reviews or fixes.
class GarageIssueRow extends StatelessWidget {
  const GarageIssueRow({super.key, required this.issue});

  final KnownIssue issue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  issue.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GarageSeverityBadge(severity: issue.severity),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            issue.description,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          for (final source in issue.sources)
            Text(
              l10n.garageIssueSources(source),
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
