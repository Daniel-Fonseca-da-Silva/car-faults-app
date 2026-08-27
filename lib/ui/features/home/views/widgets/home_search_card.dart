import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_autocomplete_field.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../home_search_options.dart';
import '../../view_models/home_search_view_model.dart';

/// Vehicle search card of the home screen.
///
/// Form state lives in [HomeSearchViewModel]. Submit is owned by the parent
/// so the home view can show loading and then push the results screen.
class HomeSearchCard extends StatelessWidget {
  const HomeSearchCard({super.key, required this.onSubmit});

  final VoidCallback onSubmit;

  static const _cardRadius = 14.0;
  static const _fieldGap = 12.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: AppColors.muted.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(l10n: l10n),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: _fieldGap,
            children: _fields(context, l10n),
          ),
          const SizedBox(height: _fieldGap),
          Consumer<HomeSearchViewModel>(
            builder: (context, viewModel, _) {
              final canPress = viewModel.canSubmit && !viewModel.isSearching;
              return AppPrimaryButton(
                icon: Icons.search,
                label: l10n.homeSearchSubmit,
                onPressed: canPress ? onSubmit : null,
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _fields(BuildContext context, AppLocalizations l10n) {
    final viewModel = context.read<HomeSearchViewModel>();

    return [
      LabeledField(
        label: l10n.homeSearchFieldBrand,
        child: AppAutocompleteField(
          hintText: l10n.homeSearchFieldBrandPlaceholder,
          suggestionsFor: HomeSearchOptions.filterBrands,
          value: viewModel.brand,
          onChanged: viewModel.setBrand,
        ),
      ),
      LabeledField(
        label: l10n.homeSearchFieldModel,
        child: AppTextField(
          hintText: l10n.homeSearchFieldModelPlaceholder,
          onChanged: viewModel.setModel,
        ),
      ),
      LabeledField(
        label: l10n.homeSearchFieldYear,
        child: Consumer<HomeSearchViewModel>(
          builder: (context, viewModel, _) {
            return AppDropdownField<int>(
              hintText: l10n.homeSearchFieldYearPlaceholder,
              options: _optionsOf(HomeSearchOptions.years()),
              value: viewModel.year,
              onChanged: viewModel.setYear,
            );
          },
        ),
      ),
      LabeledField(
        label: l10n.homeSearchFieldEngine,
        child: AppTextField(
          hintText: l10n.homeSearchFieldEnginePlaceholder,
          onChanged: viewModel.setEngine,
        ),
      ),
      LabeledField(
        label: l10n.homeSearchFieldFuel,
        child: Consumer<HomeSearchViewModel>(
          builder: (context, viewModel, _) {
            return AppDropdownField<FuelOption>(
              hintText: l10n.homeSearchFieldFuelPlaceholder,
              options: _fuelOptions(l10n),
              value: viewModel.fuel,
              onChanged: viewModel.setFuel,
            );
          },
        ),
      ),
      LabeledField(
        label: l10n.homeSearchFieldDoors,
        showOptionalBadge: true,
        child: Consumer<HomeSearchViewModel>(
          builder: (context, viewModel, _) {
            return AppDropdownField<int>(
              hintText: l10n.homeSearchFieldDoorsPlaceholder,
              options: _optionsOf(HomeSearchOptions.doors),
              value: viewModel.doors,
              onChanged: viewModel.setDoors,
            );
          },
        ),
      ),
    ];
  }

  /// Rebuilt on every build because the labels follow the active locale.
  List<AppDropdownOption<FuelOption>> _fuelOptions(AppLocalizations l10n) {
    return [
      for (final fuel in FuelOption.values)
        AppDropdownOption(value: fuel, label: fuel.label(l10n)),
    ];
  }

  static List<AppDropdownOption<T>> _optionsOf<T>(List<T> values) {
    return [
      for (final value in values)
        AppDropdownOption(value: value, label: value.toString()),
    ];
  }
}

/// Search icon and title on the left, database status on the right.
///
/// A [Wrap] instead of a [Row] because the two blocks together are wider than
/// a narrow screen: the status then drops to a second line rather than
/// overflowing or truncating the copy, which varies in length per locale.
class _Header extends StatelessWidget {
  const _Header({required this.l10n});

  final AppLocalizations l10n;

  static const _iconSize = 20.0;
  static const _dotSize = 6.0;

  @override
  Widget build(BuildContext context) {
    // The full width makes WrapAlignment.spaceBetween push the status to the
    // right edge while both blocks share a line.
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [_title(), _status()],
      ),
    );
  }

  Widget _title() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        const Icon(Icons.search, color: AppColors.primary, size: _iconSize),
        Flexible(
          child: Text(
            l10n.homeSearchTitle,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _status() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Container(
          width: _dotSize,
          height: _dotSize,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
        ),
        Flexible(
          child: Text(
            l10n.homeSearchStatusActive,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
