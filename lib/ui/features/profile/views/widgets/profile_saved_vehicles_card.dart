import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/models/saved_vehicle.dart';
import '../../../../core/theme/app_colors.dart';
import 'profile_saved_vehicle_row.dart';

/// "Veículos salvos" card: header with the saved-vehicles count and a list
/// of [ProfileSavedVehicleRow]s, or an empty-state message.
///
/// Static UI only in this slice: [vehicles] comes from
/// `ProfileDemoDisplay`, not a ViewModel or account backend.
class ProfileSavedVehiclesCard extends StatelessWidget {
  const ProfileSavedVehiclesCard({super.key, required this.vehicles});

  final List<SavedVehicle> vehicles;

  static const _borderRadius = 14.0;
  static const _padding = 20.0;
  static const _borderOpacity = 0.2;
  static const _dividerOpacity = 0.1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(_padding),
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
          Row(
            children: [
              const Icon(
                Icons.star_outline,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.profileVehiclesTitle.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Text(
                l10n.profileVehiclesCount(vehicles.length),
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (vehicles.isEmpty)
            Text(
              l10n.profileVehiclesEmpty,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            )
          else
            for (var i = 0; i < vehicles.length; i++) ...[
              if (i > 0)
                Divider(
                  color: AppColors.muted.withValues(alpha: _dividerOpacity),
                ),
              ProfileSavedVehicleRow(vehicle: vehicles[i]),
            ],
        ],
      ),
    );
  }
}
