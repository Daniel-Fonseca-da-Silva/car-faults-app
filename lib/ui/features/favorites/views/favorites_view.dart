import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/lookup_repository.dart';
import '../../../../domain/models/app_locale.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/view_models/auth_session_view_model.dart';
import '../../../core/view_models/locale_view_model.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../login/views/login_view.dart';
import '../../lookup/lookup_failure_message.dart';
import '../../lookup/view_models/lookup_results_view_model.dart';
import '../../lookup/views/lookup_results_view.dart';
import '../view_models/favorites_view_model.dart';
import 'widgets/favorites_vehicle_card.dart';

/// Favorites ("Favoritos") screen: the user's favorited vehicles, loaded
/// from [FavoritesViewModel].
class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.read<FavoritesViewModel>();
    final locale = context.read<LocaleViewModel>().locale;

    return AppScaffold(
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.removeFailed) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              viewModel.acknowledgeRemoveFailure();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.favoritesRemoveError)),
              );
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
                ..._content(l10n, viewModel, locale),
                AppFooter(disclaimer: l10n.homeDisclaimer),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _content(
    AppLocalizations l10n,
    FavoritesViewModel viewModel,
    AppLocale locale,
  ) {
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
                l10n.favoritesLoadError,
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

    if (viewModel.vehicles.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              l10n.favoritesEmpty,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
        ),
      ];
    }

    return [
      Text(
        l10n.favoritesTitle,
        style: const TextStyle(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          for (final vehicle in viewModel.vehicles)
            FavoritesVehicleCard(
              vehicle: vehicle,
              onRemove: () => viewModel.removeFavorite(vehicle),
              onTap: () => viewModel.openVehicle(vehicle, locale: locale),
              isLoading: viewModel.isOpeningVehicle(vehicle.vehicleModelId),
            ),
        ],
      ),
    ];
  }

  void _handlePendingResult(
    BuildContext context,
    AppLocalizations l10n,
    FavoritesViewModel viewModel,
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

  /// The session may have been cleared (401) since the load that put the
  /// view in its error state — redirect to sign-in instead of retrying a
  /// request that would fail the same way.
  void _retry(BuildContext context, FavoritesViewModel viewModel) {
    if (!context.read<AuthSessionViewModel>().isSignedIn) {
      pushLoginView(context);
      return;
    }
    viewModel.load();
  }
}
