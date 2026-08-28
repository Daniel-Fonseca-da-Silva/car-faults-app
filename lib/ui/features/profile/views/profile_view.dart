import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/section_eyebrow.dart';
import '../profile_demo_display.dart';
import 'widgets/profile_account_info_card.dart';
import 'widgets/profile_identity_card.dart';

/// Profile ("Conta") screen: identity card, account details and — in later
/// slices — stats, saved vehicles and the danger zone.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final snapshot = ProfileDemoDisplay.snapshot;

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            SectionEyebrow(text: l10n.profileEyebrow),
            ProfileIdentityCard(snapshot: snapshot),
            ProfileAccountInfoCard(snapshot: snapshot),
            AppFooter(disclaimer: l10n.homeDisclaimer),
          ],
        ),
      ),
    );
  }
}
