import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/require_sign_in.dart';
import '../../../../core/view_models/auth_session_view_model.dart';
import '../../view_models/lookup_results_view_model.dart';

/// "Favorite" button below [LookupAddToGarageButton]. Checks
/// `GET /v1/activity-logs/favorites/:vehicleModelId` once (if signed in) so
/// an already-favorited vehicle shows as such. Unlike the garage button,
/// this one stays a toggle: tapping it again while favorited unfavorites the
/// vehicle.
class LookupFavoriteButton extends StatefulWidget {
  const LookupFavoriteButton({super.key});

  @override
  State<LookupFavoriteButton> createState() => _LookupFavoriteButtonState();
}

class _LookupFavoriteButtonState extends State<LookupFavoriteButton> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<AuthSessionViewModel>().isSignedIn) {
        context.read<LookupResultsViewModel>().checkFavoriteStatus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.watch<LookupResultsViewModel>();
    final isFavorited = viewModel.isFavorited ?? false;
    final isBusy =
        viewModel.isTogglingFavorite || viewModel.isCheckingFavoriteStatus;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: isBusy ? null : () => _toggleFavorite(context),
        icon: Icon(isFavorited ? Icons.favorite : Icons.favorite_border),
        label: Text(isFavorited ? l10n.lookupUnfavorite : l10n.lookupFavorite),
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

  void _toggleFavorite(BuildContext context) {
    requireSignIn(context, () async {
      final l10n = AppLocalizations.of(context)!;
      final success = await context
          .read<LookupResultsViewModel>()
          .toggleFavorite();
      if (!context.mounted || success) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.lookupFavoriteError)));
    });
  }
}
