import 'package:car_faults_app/domain/models/known_issue.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../view_models/lookup_results_view_model.dart';
import 'lookup_comments_empty.dart';
import 'lookup_issue_sources.dart';
import 'lookup_reviews_section.dart';
import 'lookup_severity_badge.dart';
import 'lookup_solutions_section.dart';

/// One expansible card in the known-issues accordion: header (icon, title,
/// severity badge, meta, chevron) and, when expanded, the description,
/// sources and [LookupReviewsSection].
///
/// A custom card + [AnimatedCrossFade] rather than [ExpansionTile], whose
/// default visuals don't match the design.
class LookupIssueCard extends StatelessWidget {
  const LookupIssueCard({super.key, required this.issue});

  final KnownIssue issue;

  static const _borderRadius = 12.0;
  static const _borderOpacity = 0.3;
  static const _minHeaderHeight = 48.0;
  static const _iconSize = 32.0;
  static const _crossFadeDuration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LookupResultsViewModel>();
    final isExpanded = viewModel.isIssueExpanded(issue.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: _borderOpacity),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              issue: issue,
              isExpanded: isExpanded,
              onTap: () =>
                  context.read<LookupResultsViewModel>().toggleIssue(issue.id),
            ),
            AnimatedCrossFade(
              duration: _crossFadeDuration,
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.description,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LookupIssueSources(sources: issue.sources),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.muted),
                    const SizedBox(height: 8),
                    LookupReviewsSection(issueId: issue.id),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.muted),
                    const SizedBox(height: 8),
                    LookupSolutionsSection(fixes: issue.fixes),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.muted),
                    const SizedBox(height: 8),
                    const LookupCommentsEmpty(),
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

class _Header extends StatelessWidget {
  const _Header({
    required this.issue,
    required this.isExpanded,
    required this.onTap,
  });

  final KnownIssue issue;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(LookupIssueCard._borderRadius),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: LookupIssueCard._minHeaderHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: LookupIssueCard._iconSize,
                height: LookupIssueCard._iconSize,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.priority_high,
                  color: AppColors.onSurface,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.title,
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        LookupSeverityBadge(severity: issue.severity),
                        Text(
                          _meta(l10n, issue),
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _meta(AppLocalizations l10n, KnownIssue issue) {
    final mileage = issue.typicalKm != null
        ? l10n.lookupAtKm(issue.typicalKm!)
        : l10n.lookupMileageIndependent;
    final solutions = l10n.lookupSolutionsCount(issue.fixes.length);
    return '$mileage · $solutions';
  }
}
