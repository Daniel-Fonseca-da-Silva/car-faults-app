import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
/// saved vehicles and the danger zone.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.read<ProfileViewModel>();
    final snapshot = viewModel.snapshot;

    return AppScaffold(
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final result = viewModel.lastResult;
          if (result != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.profileDeleteComingSoon)),
              );
              viewModel.acknowledgeResult();
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                SectionEyebrow(text: l10n.profileEyebrow),
                ProfileIdentityCard(snapshot: snapshot),
                ProfileAccountInfoCard(snapshot: snapshot),
                ProfileStatsGrid(snapshot: snapshot),
                ProfileSavedVehiclesCard(vehicles: snapshot.vehicles),
                ProfileDangerZone(viewModel: viewModel),
                AppFooter(disclaimer: l10n.homeDisclaimer),
              ],
            ),
          );
        },
      ),
    );
  }
}
