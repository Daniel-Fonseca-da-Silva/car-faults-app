import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/models/favorite_vehicle.dart';
import '../../../../core/theme/app_colors.dart';

/// One favorited vehicle on the favorites screen: name, year and an
/// unfavorite action.
///
/// Tapping the row does nothing; only the heart icon is interactive in this
/// slice.
class FavoritesVehicleCard extends StatelessWidget {
  const FavoritesVehicleCard({
    super.key,
    required this.vehicle,
    required this.onRemove,
  });

  final FavoriteVehicle vehicle;
  final VoidCallback onRemove;

  static const _borderRadius = 14.0;
  static const _borderOpacity = 0.2;
  static const _minHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final removeLabel = l10n.favoritesRemoveVehicle(
      vehicle.brand,
      vehicle.model,
    );

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
                  '${vehicle.year}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: removeLabel,
            child: IconButton(
              icon: const Icon(Icons.favorite, color: AppColors.primary),
              tooltip: removeLabel,
              onPressed: onRemove,
            ),
          ),
        ],
      ),
    );
  }
}
