import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/models/saved_vehicle.dart';
import '../../../../core/theme/app_colors.dart';
import 'garage_favourite_vehicle_card.dart';

/// "Your favourite vehicles" section of the garage screen: a title and
/// either an empty-state message or a list of [GarageFavouriteVehicleCard]s.
class GarageFavouritesSection extends StatelessWidget {
  const GarageFavouritesSection({
    super.key,
    required this.vehicles,
    required this.onRemoveVehicle,
  });

  final List<SavedVehicle> vehicles;
  final ValueChanged<String> onRemoveVehicle;

  static const _borderRadius = 14.0;
  static const _borderOpacity = 0.15;
  static const _padding = 20.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          l10n.garageFavouritesTitle.toUpperCase(),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 1.2,
          ),
        ),
        if (vehicles.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(_padding),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(_borderRadius),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: _borderOpacity),
              ),
            ),
            child: Text(
              l10n.garageFavouritesEmpty,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          )
        else
          Column(
            spacing: 12,
            children: [
              for (final vehicle in vehicles)
                GarageFavouriteVehicleCard(
                  vehicle: vehicle,
                  onRemove: () => onRemoveVehicle(vehicle.id),
                ),
            ],
          ),
      ],
    );
  }
}
