import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/section_eyebrow.dart';

/// Profile screen shell: eyebrow and footer only. Identity, account info,
/// stats, vehicles and the danger zone are added in later slices.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionEyebrow(text: l10n.profileEyebrow),
            AppFooter(disclaimer: l10n.homeDisclaimer),
          ],
        ),
      ),
    );
  }
}
