import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../view_models/lookup_results_view_model.dart';
import 'widgets/lookup_back_link.dart';
import 'widgets/lookup_issue_card.dart';
import 'widgets/lookup_issues_summary.dart';
import 'widgets/lookup_tech_specs.dart';
import 'widgets/lookup_vehicle_hero.dart';

/// Fault lookup results screen: shared header, back-to-search link, vehicle
/// hero, tech specs grid, issues summary banner, known-issues accordion
/// (with reviews) and shared footer.
///
/// The body between the accordion and the footer is filled in by later
/// slices (fixes, comments).
class LookupResultsView extends StatelessWidget {
  const LookupResultsView({super.key, this.viewModel});

  final LookupResultsViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => viewModel ?? LookupResultsViewModel(),
      child: const _LookupResultsBody(),
    );
  }
}

class _LookupResultsBody extends StatelessWidget {
  const _LookupResultsBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final issues = context.watch<LookupResultsViewModel>().issues;

    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            LookupBackLink(onPressed: () => Navigator.of(context).pop()),
            const SizedBox(height: 12),
            const LookupVehicleHero(),
            const SizedBox(height: 16),
            const LookupTechSpecs(),
            const SizedBox(height: 16),
            const LookupIssuesSummary(),
            const SizedBox(height: 16),
            for (final issue in issues) ...[
              LookupIssueCard(issue: issue),
              const SizedBox(height: 12),
            ],
            AppFooter(disclaimer: l10n.homeDisclaimer),
          ],
        ),
      ),
    );
  }
}
