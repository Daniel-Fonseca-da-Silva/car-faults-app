import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/models/saved_vehicle.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../lookup/views/lookup_results_view.dart';

/// One row of [ProfileSavedVehiclesCard]: icon square, vehicle name and
/// year range, known-issues pill and a chevron.
///
/// Tapping the row opens [LookupResultsView]. Every row navigates to the
/// same demo results screen — the lookup feature has no per-vehicle data
/// yet, a limitation already accepted there.
class ProfileSavedVehicleRow extends StatelessWidget {
  const ProfileSavedVehicleRow({super.key, required this.vehicle});

  final SavedVehicle vehicle;

  static const _iconSize = 40.0;
  static const _iconBorderRadius = 10.0;
  static const _rowBorderRadius = 12.0;
  static const _minHeight = 48.0;
  static const _iconBackgroundOpacity = 0.16;
  static const _pillBorderOpacity = 0.4;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      button: true,
      label: l10n.profileViewVehicleDetails(vehicle.brand, vehicle.model),
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(_rowBorderRadius),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const LookupResultsView()),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: _iconSize,
                  height: _iconSize,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(
                      alpha: _iconBackgroundOpacity,
                    ),
                    borderRadius: BorderRadius.circular(_iconBorderRadius),
                  ),
                  child: const Icon(
                    Icons.build,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehicle.brand} ${vehicle.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${vehicle.yearFrom}–${vehicle.yearTo}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.primary.withValues(
                        alpha: _pillBorderOpacity,
                      ),
                    ),
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
                        l10n.profileKnownIssuesCount(vehicle.knownIssuesCount),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
