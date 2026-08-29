import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/models/saved_vehicle.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

/// Hero card at the top of the garage screen: garage photo, gradient
/// overlay and the currently selected vehicle's name and year, or an
/// empty-garage title when there is none.
class GarageHeroCard extends StatelessWidget {
  const GarageHeroCard({super.key, required this.selectedVehicle});

  final SavedVehicle? selectedVehicle;

  static const _aspectRatio = 16 / 9;
  static const _borderRadius = 16.0;
  static const _overlayMidStop = 0.55;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vehicle = selectedVehicle;

    return ClipRRect(
      borderRadius: BorderRadius.circular(_borderRadius),
      child: AspectRatio(
        aspectRatio: _aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Semantics(
              label: l10n.garageHeroImageAlt,
              image: true,
              child: Image.asset(AppAssets.garage, fit: BoxFit.cover),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, _overlayMidStop, 1],
                  colors: [
                    AppColors.background.withValues(alpha: 0),
                    AppColors.background.withValues(alpha: 0.5),
                    AppColors.background,
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.garageEyebrow.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vehicle == null
                        ? l10n.garageEmptyTitle
                        : '${vehicle.brand} ${vehicle.model}',
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                      height: 1.15,
                    ),
                  ),
                  if (vehicle != null)
                    Text(
                      '${vehicle.yearFrom}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
