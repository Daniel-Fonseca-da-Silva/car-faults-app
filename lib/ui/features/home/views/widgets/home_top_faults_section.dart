import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../home_top_faults_display.dart';
import 'top_fault_card.dart';

/// "Most reported faults" section: header with a warning icon and title,
/// followed by a [TopFaultCard] per [HomeTopFaultsDisplay] entry.
///
/// Static UI only in this slice: no ViewModel, no external data.
class HomeTopFaultsSection extends StatelessWidget {
  const HomeTopFaultsSection({super.key});

  static const _cardGap = 12.0;
  static const _ruleHeight = 1.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(l10n),
          const SizedBox(height: 16),
          Semantics(
            container: true,
            label: l10n.homeTopFaultsSemanticLabel,
            child: Column(
              spacing: _cardGap,
              children: [
                for (final entry in HomeTopFaultsDisplay.entries)
                  TopFaultCard(
                    entry: entry,
                    description: entry.faultDescription(l10n),
                    viewReportsLabel: l10n.homeTopFaultsViewReports,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(AppLocalizations l10n) {
    return Row(
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          color: AppColors.primary,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          l10n.homeTopFaultsTitle,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: _ruleHeight,
            color: AppColors.muted.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}
