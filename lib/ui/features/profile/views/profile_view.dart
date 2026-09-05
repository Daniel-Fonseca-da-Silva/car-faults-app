import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/view_models/auth_session_view_model.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/section_eyebrow.dart';
import '../view_models/profile_view_model.dart';
import 'widgets/profile_account_info_card.dart';
import 'widgets/profile_danger_zone.dart';
import 'widgets/profile_identity_card.dart';
import 'widgets/profile_saved_vehicles_card.dart';
import 'widgets/profile_stats_grid.dart';

/// Profile ("Conta") screen: identity card, account details, stats grid,
/// saved vehicles and the danger zone, loaded from [ProfileViewModel].
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.read<ProfileViewModel>();

    return AppScaffold(
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final result = viewModel.lastResult;
          if (result != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              _handleDeleteResult(context, l10n, viewModel, result);
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                SectionEyebrow(text: l10n.profileEyebrow),
                _content(l10n, viewModel),
                AppFooter(disclaimer: l10n.homeDisclaimer),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _content(AppLocalizations l10n, ProfileViewModel viewModel) {
    final snapshot = viewModel.snapshot;

    if (snapshot == null && viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (snapshot == null && viewModel.hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Text(
              l10n.profileLoadError,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            TextButton(onPressed: viewModel.load, child: Text(l10n.legalRetry)),
          ],
        ),
      );
    }

    if (snapshot == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        ProfileIdentityCard(snapshot: snapshot),
        ProfileAccountInfoCard(snapshot: snapshot),
        ProfileStatsGrid(snapshot: snapshot),
        ProfileSavedVehiclesCard(vehicles: snapshot.vehicles),
        ProfileDangerZone(viewModel: viewModel),
      ],
    );
  }

  void _handleDeleteResult(
    BuildContext context,
    AppLocalizations l10n,
    ProfileViewModel viewModel,
    DeleteAccountResult result,
  ) {
    viewModel.acknowledgeResult();
    switch (result) {
      case DeleteAccountSuccess():
        context.read<AuthSessionViewModel>().signOut();
        Navigator.of(context).pop();
      case DeleteAccountFailure():
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.profileDeleteError)));
    }
  }
}
