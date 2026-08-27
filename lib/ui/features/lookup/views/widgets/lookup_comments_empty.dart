import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// "COMENTÁRIOS DA COMUNIDADE" section inside an expanded [LookupIssueCard]:
/// title followed by the dashed-icon empty state. The mock data has no
/// comments, so this is the only state rendered for now.
class LookupCommentsEmpty extends StatelessWidget {
  const LookupCommentsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              color: AppColors.primary,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              l10n.lookupCommentsTitle.toUpperCase(),
              style: const TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                color: AppColors.muted,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.lookupCommentsEmpty,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
