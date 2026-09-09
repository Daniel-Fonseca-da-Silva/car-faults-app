import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/lookup_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/view_models/auth_session_view_model.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../login/views/login_view.dart';
import '../../lookup/lookup_failure_message.dart';
import '../../lookup/view_models/lookup_results_view_model.dart';
import '../../lookup/views/lookup_results_view.dart';
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

          final pendingResult = viewModel.pendingResult;
          if (pendingResult != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              _handlePendingResult(context, l10n, viewModel, pendingResult);
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
              Builder(
                builder: (context) => TextButton(
                  onPressed: () => _retry(context, viewModel),
                  child: Text(l10n.legalRetry),
                ),
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
        onSelectVehicle: viewModel.selectVehicle,
        selectedVehicleId: viewModel.selectedVehicle?.id,
      ),
      GarageKnownIssuesSection(
        issues: viewModel.issues,
        onViewDetails: viewModel.selectedVehicle == null
            ? null
            : () => viewModel.openVehicle(viewModel.selectedVehicle!),
        isOpening:
            viewModel.selectedVehicle != null &&
            viewModel.isOpeningVehicle(viewModel.selectedVehicle!.id),
      ),
    ];
  }

  /// The session may have been cleared (401) since the load that put the
  /// view in its error state — redirect to sign-in instead of retrying a
  /// request that would fail the same way.
  void _retry(BuildContext context, GarageViewModel viewModel) {
    if (!context.read<AuthSessionViewModel>().isSignedIn) {
      pushLoginView(context);
      return;
    }
    viewModel.load();
  }

  void _handlePendingResult(
    BuildContext context,
    AppLocalizations l10n,
    GarageViewModel viewModel,
    LookupSearchResult result,
  ) {
    viewModel.acknowledgePendingResult();

    switch (result) {
      case LookupSearchSuccess(:final vehicle, :final issues):
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => LookupResultsView(
              viewModel: LookupResultsViewModel(
                vehicle: vehicle,
                issues: issues,
                searchedYear: viewModel.pendingSearchedYear,
              ),
            ),
          ),
        );
      case LookupSearchFailure(:final reason):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(lookupFailureMessage(l10n, reason))),
        );
    }
  }
}
