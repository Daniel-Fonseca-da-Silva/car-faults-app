import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_scaffold.dart';
import 'widgets/lookup_back_link.dart';
import 'widgets/lookup_vehicle_hero.dart';

/// Fault lookup results screen: shared header, back-to-search link, vehicle
/// hero and shared footer.
///
/// The body between the hero and the footer is filled in by later slices
/// (specs, defects, reviews, fixes, comments).
class LookupResultsView extends StatelessWidget {
  const LookupResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            LookupBackLink(onPressed: () => Navigator.of(context).pop()),
            const SizedBox(height: 12),
            const LookupVehicleHero(),
            AppFooter(disclaimer: l10n.homeDisclaimer),
          ],
        ),
      ),
    );
  }
}
