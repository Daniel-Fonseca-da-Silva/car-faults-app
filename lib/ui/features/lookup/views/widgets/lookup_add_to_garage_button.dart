import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/repositories/garage_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/require_sign_in.dart';
import '../../../../core/view_models/auth_session_view_model.dart';
import '../../view_models/lookup_results_view_model.dart';

/// "Add to garage" button below [LookupVehicleHero]. Checks
/// `GET /v1/user-vehicles/status` once (if signed in) so an already-owned
/// vehicle shows as such instead of offering to add it again.
class LookupAddToGarageButton extends StatefulWidget {
  const LookupAddToGarageButton({super.key});

  @override
  State<LookupAddToGarageButton> createState() =>
      _LookupAddToGarageButtonState();
}

class _LookupAddToGarageButtonState extends State<LookupAddToGarageButton> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<AuthSessionViewModel>().isSignedIn) {
        context.read<LookupResultsViewModel>().checkGarageStatus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.watch<LookupResultsViewModel>();
    final isInGarage = viewModel.isInGarage ?? false;
    final isBusy =
        viewModel.isAddingToGarage || viewModel.isCheckingGarageStatus;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: isInGarage || isBusy ? null : () => _addToGarage(context),
        icon: Icon(isInGarage ? Icons.check_circle : Icons.garage_outlined),
        label: Text(
          isInGarage ? l10n.lookupAddToGarageAlready : l10n.lookupAddToGarage,
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: AppColors.onSurface,
          disabledForegroundColor: AppColors.muted,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _addToGarage(BuildContext context) {
    requireSignIn(context, () async {
      final l10n = AppLocalizations.of(context)!;
      final result = await context.read<LookupResultsViewModel>().addToGarage();
      if (!context.mounted) return;

      final message = switch (result) {
        AddToGarageSuccess() => null,
        AddToGarageDuplicate() => l10n.lookupAddToGarageDuplicate,
        AddToGarageFailure() => l10n.lookupAddToGarageError,
      };
      if (message != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    });
  }
}
