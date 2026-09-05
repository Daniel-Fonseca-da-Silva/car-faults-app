import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/lookup_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/view_models/locale_view_model.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../lookup/view_models/lookup_results_view_model.dart';
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
      create: (context) =>
          viewModel ??
          HomeSearchViewModel(repository: context.read<LookupRepository>()),
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

    final result = viewModel.lastResult;
    if (result != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        _handleResult(context, l10n, viewModel, result);
      });
    }

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
    final locale = context.read<LocaleViewModel>().locale;
    await viewModel.search(locale: locale);
  }

  void _handleResult(
    BuildContext context,
    AppLocalizations l10n,
    HomeSearchViewModel viewModel,
    LookupSearchResult result,
  ) {
    viewModel.acknowledgeResult();

    switch (result) {
      case LookupSearchSuccess(:final vehicle, :final issues):
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => LookupResultsView(
              viewModel: LookupResultsViewModel(
                vehicle: vehicle,
                issues: issues,
              ),
            ),
          ),
        );
      case LookupSearchFailure(:final reason):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_failureMessage(l10n, reason))));
    }
  }

  String _failureMessage(AppLocalizations l10n, LookupFailureReason reason) {
    return switch (reason) {
      LookupFailureReason.rateLimited => l10n.homeSearchErrorRateLimited,
      LookupFailureReason.unavailable => l10n.homeSearchErrorUnavailable,
      LookupFailureReason.notFound => l10n.homeSearchErrorNotFound,
      LookupFailureReason.network ||
      LookupFailureReason.unknown => l10n.homeSearchErrorGeneric,
    };
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
