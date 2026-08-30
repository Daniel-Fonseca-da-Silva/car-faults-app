import 'package:car_faults_app/domain/models/issue_fix.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/require_sign_in.dart';
import '../../view_models/lookup_results_view_model.dart';

/// One card inside [LookupSolutionsSection]: check icon, summary, price
/// badge, an expansible numbered how-to and local ÚTIL? thumbs voting.
class LookupFixCard extends StatelessWidget {
  const LookupFixCard({super.key, required this.fix});

  final IssueFix fix;

  static const _borderRadius = 12.0;
  static const _borderOpacity = 0.3;
  static const _minTapTarget = 48.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.watch<LookupResultsViewModel>();
    final isExpanded = viewModel.isFixExpanded(fix.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: _borderOpacity),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fix.summary,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _CostBadge(amount: fix.estimatedCostEur),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () =>
                context.read<LookupResultsViewModel>().toggleFixSteps(fix.id),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isExpanded ? Icons.expand_less : Icons.chevron_right,
                  color: AppColors.primary,
                  size: 18,
                ),
                Text(
                  isExpanded
                      ? l10n.lookupHideSteps
                      : l10n.lookupViewSteps(fix.steps.length),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 8),
            for (var i = 0; i < fix.steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text(
                        '${i + 1}.',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        fix.steps[i],
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 8),
          const Divider(color: AppColors.muted),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                l10n.lookupHelpful,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(width: 12),
              _VoteButton(
                icon: Icons.thumb_up_outlined,
                count: viewModel.likesFor(fix.id),
                onTap: () => requireSignIn(
                  context,
                  () => context.read<LookupResultsViewModel>().voteLike(fix.id),
                ),
              ),
              const SizedBox(width: 8),
              _VoteButton(
                icon: Icons.thumb_down_outlined,
                count: viewModel.dislikesFor(fix.id),
                onTap: () => requireSignIn(
                  context,
                  () => context.read<LookupResultsViewModel>().voteDislike(
                    fix.id,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CostBadge extends StatelessWidget {
  const _CostBadge({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary),
      ),
      child: Text(
        l10n.lookupCostEur(amount),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

/// Outline thumbs-up/thumbs-down button with an ≥ 48 dp tap target.
class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.icon,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: LookupFixCard._minTapTarget,
          minHeight: LookupFixCard._minTapTarget,
        ),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.muted.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.muted, size: 16),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
