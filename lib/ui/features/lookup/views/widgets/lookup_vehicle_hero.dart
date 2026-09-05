import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/section_eyebrow.dart';
import '../../lookup_demo_display.dart';
import '../../view_models/lookup_results_view_model.dart';

/// Card at the top of the results screen showing the matched vehicle's
/// photo, name and model, matching [LoginHeroSection]'s gradient pattern.
///
/// The vehicle comes from [LookupResultsViewModel]; the hero photo is still
/// a fixed placeholder ([LookupDemoDisplay.vehicleImage]) since the API's
/// vehicle image isn't wired up yet.
class LookupVehicleHero extends StatelessWidget {
  const LookupVehicleHero({super.key});

  static const _aspectRatio = 16 / 9;
  static const _borderRadius = 16.0;
  static const _overlayMidStop = 0.55;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vehicle = context.watch<LookupResultsViewModel>().vehicle;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_borderRadius),
        child: AspectRatio(
          aspectRatio: _aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Semantics(
                label: l10n.lookupHeroImageAlt,
                image: true,
                child: Image.asset(
                  LookupDemoDisplay.vehicleImage,
                  fit: BoxFit.cover,
                ),
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
                    SectionEyebrow(text: l10n.lookupVehicleFound),
                    const SizedBox(height: 8),
                    Text(
                      '${vehicle.brand} ${vehicle.model}',
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                        height: 1.15,
                      ),
                    ),
                    Text(
                      vehicle.name,
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
      ),
    );
  }
}
