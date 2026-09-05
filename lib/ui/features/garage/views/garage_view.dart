import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../view_models/garage_view_model.dart';
import 'widgets/garage_hero_card.dart';
import 'widgets/garage_known_issues_section.dart';
import 'widgets/garage_vehicles_section.dart';

/// Garage ("Garagem") screen: the user's saved vehicles and known issues,
/// loaded from [GarageViewModel].
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
          if (viewModel.removeFailed) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              viewModel.acknowledgeRemoveFailure();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.garageRemoveError)));
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                ..._content(l10n, viewModel),
                AppFooter(disclaimer: l10n.homeDisclaimer),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _content(AppLocalizations l10n, GarageViewModel viewModel) {
    if (viewModel.vehicles.isEmpty && viewModel.isLoading) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (viewModel.vehicles.isEmpty && viewModel.hasError) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Text(
                l10n.garageLoadError,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              TextButton(
                onPressed: viewModel.load,
                child: Text(l10n.legalRetry),
              ),
            ],
          ),
        ),
      ];
    }

    return [
      GarageHeroCard(selectedVehicle: viewModel.selectedVehicle),
      GarageVehiclesSection(
        vehicles: viewModel.vehicles,
        onRemoveVehicle: viewModel.removeVehicle,
      ),
      GarageKnownIssuesSection(issues: viewModel.issues),
    ];
  }
}
