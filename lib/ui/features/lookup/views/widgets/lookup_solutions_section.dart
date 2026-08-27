import 'package:car_faults_app/domain/models/issue_fix.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'lookup_fix_card.dart';

/// "SOLUÇÕES DA COMUNIDADE (N)" section inside an expanded [LookupIssueCard]:
/// title followed by one [LookupFixCard] per community fix.
class LookupSolutionsSection extends StatelessWidget {
  const LookupSolutionsSection({super.key, required this.fixes});

  final List<IssueFix> fixes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.lookupCommunitySolutions(fixes.length).toUpperCase(),
          style: const TextStyle(
            color: AppColors.muted,
            fontWeight: FontWeight.w600,
            fontSize: 11,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 12),
        for (final fix in fixes)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LookupFixCard(fix: fix),
          ),
      ],
    );
  }
}
