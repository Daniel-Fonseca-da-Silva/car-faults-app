import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/repositories/platform_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_count.dart';
import '../../../../core/widgets/stat_item.dart';
import '../../view_models/home_stats_view_model.dart';

/// Stats bar below the vehicle search card: faults, models and recalls.
///
/// Loads live platform stats via [HomeStatsViewModel] on mount.
class HomeStatsSection extends StatefulWidget {
  const HomeStatsSection({super.key, this.viewModel});

  /// Overridable for tests; defaults to a fresh [HomeStatsViewModel] built
  /// from the app-wide [PlatformRepository].
  final HomeStatsViewModel? viewModel;

  @override
  State<HomeStatsSection> createState() => _HomeStatsSectionState();
}

class _HomeStatsSectionState extends State<HomeStatsSection> {
  late final HomeStatsViewModel _viewModel;

  static const _horizontalRule = BorderSide(color: AppColors.surface);
  static const _columnDividerWidth = 1.0;
  static const _columnDividerHeight = 32.0;

  @override
  void initState() {
    super.initState();
    _viewModel =
        widget.viewModel ??
        HomeStatsViewModel(repository: context.read<PlatformRepository>());
    if (_viewModel.stats == null && !_viewModel.isLoading) {
      _viewModel.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      container: true,
      label: l10n.homeStatsSemanticLabel,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          border: Border(top: _horizontalRule, bottom: _horizontalRule),
        ),
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) => _body(l10n),
        ),
      ),
    );
  }

  Widget _body(AppLocalizations l10n) {
    final stats = _viewModel.stats;

    if (_viewModel.isLoading && stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_viewModel.hasError && stats == null) {
      return _errorState(l10n);
    }

    if (stats == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: StatItem(
            value: formatCount(stats.faultsCount),
            label: l10n.homeStatFaults,
          ),
        ),
        _columnDivider(),
        Expanded(
          child: StatItem(
            value: formatCount(stats.vehiclesCount),
            label: l10n.homeStatModels,
          ),
        ),
        _columnDivider(),
        Expanded(
          child: StatItem(
            value: formatCount(stats.reportsCount),
            label: l10n.homeStatRecalls,
          ),
        ),
      ],
    );
  }

  Widget _errorState(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.homeStatsLoadError,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        TextButton(onPressed: _viewModel.load, child: Text(l10n.legalRetry)),
      ],
    );
  }

  Widget _columnDivider() {
    return Container(
      width: _columnDividerWidth,
      height: _columnDividerHeight,
      color: AppColors.primary,
    );
  }
}
