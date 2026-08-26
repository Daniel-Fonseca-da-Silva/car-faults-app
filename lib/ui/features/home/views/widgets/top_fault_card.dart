import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../home_top_faults_display.dart';

/// Single "most reported fault" card: brand/model/year, a report-count badge,
/// the fault description and a decorative "view reports" footer.
///
/// No `onTap` in this slice — neither the card nor the footer link navigate.
class TopFaultCard extends StatelessWidget {
  const TopFaultCard({
    super.key,
    required this.entry,
    required this.description,
    required this.viewReportsLabel,
  });

  final TopFaultEntry entry;
  final String description;
  final String viewReportsLabel;

  static const _cardRadius = 12.0;
  static const _badgeRadius = 999.0;
  static const _dividerHeight = 1.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${entry.brand} ${entry.model}, ${entry.year}, $description, '
          '${formatReportCount(entry.reportCount)}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(_cardRadius),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Container(
              height: _dividerHeight,
              color: AppColors.muted.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 12),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${entry.brand} ${entry.model}',
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${entry.year}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _badge(),
      ],
    );
  }

  Widget _badge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_badgeRadius),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: AppColors.primary,
            size: 14,
          ),
          Text(
            formatReportCount(entry.reportCount),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          viewReportsLabel,
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const Icon(Icons.arrow_forward, color: AppColors.muted, size: 16),
      ],
    );
  }
}
