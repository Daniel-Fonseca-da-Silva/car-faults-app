import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/models/saved_vehicle.dart';
import '../../../../core/theme/app_colors.dart';

/// One favourite vehicle on the garage screen: name, year, known-issues
/// pill and a delete action.
///
/// Tapping the row does nothing; only the delete icon is interactive in
/// this slice.
class GarageFavouriteVehicleCard extends StatelessWidget {
  const GarageFavouriteVehicleCard({
    super.key,
    required this.vehicle,
    required this.onRemove,
  });

  final SavedVehicle vehicle;
  final VoidCallback onRemove;

  static const _borderRadius = 14.0;
  static const _borderOpacity = 0.2;
  static const _pillBorderOpacity = 0.4;
  static const _minHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final removeLabel = l10n.garageRemoveVehicle(vehicle.brand, vehicle.model);

    return Container(
      constraints: const BoxConstraints(minHeight: _minHeight),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: _borderOpacity),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${vehicle.brand} ${vehicle.model}',
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
                  '${vehicle.yearFrom}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: _pillBorderOpacity),
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
          Semantics(
            button: true,
            label: removeLabel,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.primary),
              tooltip: removeLabel,
              onPressed: onRemove,
            ),
          ),
        ],
      ),
    );
  }
}
