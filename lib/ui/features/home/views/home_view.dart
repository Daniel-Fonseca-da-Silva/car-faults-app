import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_scaffold.dart';
import 'widgets/home_hero_section.dart';
import 'widgets/home_search_card.dart';
import 'widgets/home_stats_section.dart';
import 'widgets/home_top_faults_section.dart';

/// Home screen: shared header, hero, vehicle search card, stats bar, most
/// reported faults and shared footer.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const HomeHeroSection(),
            const SizedBox(height: 24),
            const HomeSearchCard(),
            const HomeStatsSection(),
            const HomeTopFaultsSection(),
            AppFooter(disclaimer: l10n.homeDisclaimer),
          ],
        ),
      ),
    );
  }
}
