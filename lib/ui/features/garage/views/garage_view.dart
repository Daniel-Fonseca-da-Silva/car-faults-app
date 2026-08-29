import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../view_models/garage_view_model.dart';
import 'widgets/garage_favourites_section.dart';
import 'widgets/garage_hero_card.dart';

/// Garage ("Garagem") screen: the user's saved vehicles and known issues.
///
/// This slice adds the favourite vehicles section; known issues land in a
/// later slice.
class GarageView extends StatelessWidget {
  const GarageView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.read<GarageViewModel>();

    return AppScaffold(
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                GarageHeroCard(selectedVehicle: viewModel.selectedVehicle),
                GarageFavouritesSection(
                  vehicles: viewModel.vehicles,
                  onRemoveVehicle: viewModel.removeVehicle,
                ),
                AppFooter(disclaimer: l10n.homeDisclaimer),
              ],
            ),
          );
        },
      ),
    );
  }
}
