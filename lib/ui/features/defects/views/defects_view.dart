import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/mappers/locale_mapper.dart';
import '../../../../data/repositories/lookup_repository.dart';
import '../../../../data/repositories/platform_repository.dart';
import '../../../../domain/models/app_locale.dart';
import '../../../../domain/models/top_fault.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/view_models/locale_view_model.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../home/views/widgets/top_fault_card.dart';
import '../../lookup/lookup_failure_message.dart';
import '../../lookup/view_models/lookup_results_view_model.dart';
import '../../lookup/views/lookup_results_view.dart';
import '../view_models/defects_view_model.dart';

/// Full "Defeitos" screen: the platform-wide most-reported-faults ranking,
/// paginated with infinite scroll — the full-screen counterpart to the
/// home screen's fixed top-6 teaser.
class DefectsView extends StatefulWidget {
  const DefectsView({super.key, this.viewModel});

  /// Overridable for tests; defaults to a fresh [DefectsViewModel] built
  /// from the app-wide [PlatformRepository].
  final DefectsViewModel? viewModel;

  @override
  State<DefectsView> createState() => _DefectsViewState();
}

class _DefectsViewState extends State<DefectsView> {
  late final DefectsViewModel _viewModel;
  final _scrollController = ScrollController();
  AppLocale? _requestedLocale;
  int? _lastOpenedYear;

  static const _loadMoreThreshold = 200.0;

  @override
  void initState() {
    super.initState();
    _viewModel =
        widget.viewModel ??
        DefectsViewModel(repository: context.read<PlatformRepository>());
    _scrollController.addListener(_onScroll);
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
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.position.hasContentDimensions) return;
    final remaining =
        _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    if (remaining <= _loadMoreThreshold) {
      _viewModel.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final pendingResult = _viewModel.pendingResult;
          if (pendingResult != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              _handlePendingResult(context, l10n, pendingResult);
            });
          }

          return _body(l10n);
        },
      ),
    );
  }

  Widget _body(AppLocalizations l10n) {
    if (_viewModel.isLoading && _viewModel.faults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_viewModel.hasError && _viewModel.faults.isEmpty) {
      return _messageState(
        message: l10n.defectsLoadError,
        onRetry: () {
          final locale = _requestedLocale;
          if (locale != null) _viewModel.load(locale);
        },
        retryLabel: l10n.legalRetry,
      );
    }

    if (_viewModel.faults.isEmpty) {
      return _messageState(message: l10n.defectsEmpty);
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _viewModel.faults.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == _viewModel.faults.length) {
          return _listFooter(l10n);
        }

        final fault = _viewModel.faults[index];
        // vehicleEngine is always present per `TopFaultVehicleDto`; the null
        // check here only guards the nullable Dart field defensively.
        final canOpen = fault.vehicleEngine != null;
        final requestedLocale = _requestedLocale;
        final isOtherLanguage =
            requestedLocale != null &&
            fault.contentLocale != apiLanguageFor(requestedLocale);
        return TopFaultCard(
          fault: fault,
          viewReportsLabel: l10n.homeTopFaultsViewReports,
          isLoading: _viewModel.isOpeningFault(fault.id),
          onTap: canOpen ? () => _openVehicle(fault) : null,
          otherLanguageNotice: isOtherLanguage
              ? l10n.homeTopFaultsOtherLanguageNotice
              : null,
        );
      },
    );
  }

  Widget _listFooter(AppLocalizations l10n) {
    if (_viewModel.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_viewModel.hasMoreError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              l10n.defectsLoadMoreError,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            TextButton(
              onPressed: _viewModel.loadMore,
              child: Text(l10n.legalRetry),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _messageState({
    required String message,
    VoidCallback? onRetry,
    String? retryLabel,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: Text(retryLabel!)),
          ],
        ),
      ),
    );
  }

  Future<void> _openVehicle(TopFault fault) async {
    final locale = context.read<LocaleViewModel>().locale;
    _lastOpenedYear = fault.vehicleYearFrom;
    await _viewModel.openVehicle(fault, locale: locale);
  }

  void _handlePendingResult(
    BuildContext context,
    AppLocalizations l10n,
    LookupSearchResult result,
  ) {
    _viewModel.acknowledgePendingResult();

    switch (result) {
      case LookupSearchSuccess(:final vehicle, :final issues):
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => LookupResultsView(
              viewModel: LookupResultsViewModel(
                vehicle: vehicle,
                issues: issues,
                searchedYear: _lastOpenedYear,
              ),
            ),
          ),
        );
      case LookupSearchFailure(:final reason):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(lookupFailureMessage(l10n, reason))),
        );
    }
  }
}
