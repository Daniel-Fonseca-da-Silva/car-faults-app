import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/repositories/platform_repository.dart';
import '../../../../../domain/models/app_locale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../view_models/home_top_faults_view_model.dart';
import 'top_fault_card.dart';

/// "Most reported faults" section: header with a warning icon and title,
/// followed by a [TopFaultCard] per fault loaded by [HomeTopFaultsViewModel].
class HomeTopFaultsSection extends StatefulWidget {
  const HomeTopFaultsSection({super.key, this.viewModel});

  /// Overridable for tests; defaults to a fresh [HomeTopFaultsViewModel]
  /// built from the app-wide [PlatformRepository].
  final HomeTopFaultsViewModel? viewModel;

  @override
  State<HomeTopFaultsSection> createState() => _HomeTopFaultsSectionState();
}

class _HomeTopFaultsSectionState extends State<HomeTopFaultsSection> {
  late final HomeTopFaultsViewModel _viewModel;
  AppLocale? _requestedLocale;

  static const _cardGap = 12.0;
  static const _ruleHeight = 1.0;

  @override
  void initState() {
    super.initState();
    _viewModel =
        widget.viewModel ??
        HomeTopFaultsViewModel(repository: context.read<PlatformRepository>());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = appLocaleFromLanguageCode(
      Localizations.localeOf(context).languageCode,
    );
    if (_requestedLocale == locale) return;
    _requestedLocale = locale;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _viewModel.load(locale);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(l10n),
          const SizedBox(height: 16),
          Semantics(
            container: true,
            label: l10n.homeTopFaultsSemanticLabel,
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) => _body(l10n),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(AppLocalizations l10n) {
    if (_viewModel.isLoading && _viewModel.faults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_viewModel.hasError && _viewModel.faults.isEmpty) {
      return _errorState(l10n);
    }

    return Column(
      spacing: _cardGap,
      children: [
        for (final fault in _viewModel.faults)
          TopFaultCard(
            fault: fault,
            viewReportsLabel: l10n.homeTopFaultsViewReports,
          ),
      ],
    );
  }

  Widget _errorState(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.homeTopFaultsLoadError,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        TextButton(
          onPressed: () {
            final locale = _requestedLocale;
            if (locale != null) _viewModel.load(locale);
          },
          child: Text(l10n.legalRetry),
        ),
      ],
    );
  }

  Widget _header(AppLocalizations l10n) {
    return Row(
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          color: AppColors.primary,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          l10n.homeTopFaultsTitle,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: _ruleHeight,
            color: AppColors.muted.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}
