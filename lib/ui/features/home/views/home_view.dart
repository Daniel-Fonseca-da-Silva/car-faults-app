import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../lookup/views/lookup_results_view.dart';
import '../view_models/home_search_view_model.dart';
import 'widgets/home_hero_section.dart';
import 'widgets/home_search_card.dart';
import 'widgets/home_stats_section.dart';
import 'widgets/home_top_faults_section.dart';

/// Home screen: shared header, hero, vehicle search card, stats bar, most
/// reported faults and shared footer.
class HomeView extends StatelessWidget {
  const HomeView({super.key, this.viewModel});

  final HomeSearchViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => viewModel ?? HomeSearchViewModel(),
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.watch<HomeSearchViewModel>();

    return AppScaffold(
      body: viewModel.isSearching
          ? _SearchingBody(label: l10n.homeSearchSearching)
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const HomeHeroSection(),
                  const SizedBox(height: 24),
                  HomeSearchCard(onSubmit: () => _search(context)),
                  const HomeStatsSection(),
                  const HomeTopFaultsSection(),
                  AppFooter(disclaimer: l10n.homeDisclaimer),
                ],
              ),
            ),
    );
  }

  Future<void> _search(BuildContext context) async {
    final viewModel = context.read<HomeSearchViewModel>();
    await viewModel.search();
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const LookupResultsView(),
      ),
    );
  }
}

class _SearchingBody extends StatelessWidget {
  const _SearchingBody({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 16,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          Text(label, style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}
