import 'package:flutter/material.dart';

import '../../../../../domain/models/top_fault.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_count.dart';

/// Single "most reported fault" card: brand/model/year, a report-count badge,
/// the fault title and a decorative "view reports" footer.
///
/// No `onTap` in this slice — neither the card nor the footer link navigate.
class TopFaultCard extends StatelessWidget {
  const TopFaultCard({
    super.key,
    required this.fault,
    required this.viewReportsLabel,
  });

  final TopFault fault;
  final String viewReportsLabel;

  static const _cardRadius = 12.0;
  static const _badgeRadius = 999.0;
  static const _dividerHeight = 1.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${fault.vehicleBrand} ${fault.vehicleModel}, '
          '${fault.vehicleYearFrom}, ${fault.title}, '
          '${formatCount(fault.reportCount)}',
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
              fault.title,
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
                '${fault.vehicleBrand} ${fault.vehicleModel}',
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${fault.vehicleYearFrom}',
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
            formatCount(fault.reportCount),
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
