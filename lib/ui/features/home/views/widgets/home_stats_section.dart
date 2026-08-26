import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/stat_item.dart';
import '../../home_stats_display.dart';

/// Static stats bar below the vehicle search card: faults, models and recalls.
///
/// Values come from [HomeStatsDisplay] — this slice does not call the API.
class HomeStatsSection extends StatelessWidget {
  const HomeStatsSection({super.key});

  static const _horizontalRule = BorderSide(color: AppColors.surface);
  static const _columnDividerWidth = 1.0;
  static const _columnDividerHeight = 32.0;

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
        child: Row(
          children: [
            Expanded(
              child: StatItem(
                value: HomeStatsDisplay.faultsValue,
                label: l10n.homeStatFaults,
              ),
            ),
            _columnDivider(),
            Expanded(
              child: StatItem(
                value: HomeStatsDisplay.modelsValue,
                label: l10n.homeStatModels,
              ),
            ),
            _columnDivider(),
            Expanded(
              child: StatItem(
                value: HomeStatsDisplay.recallsValue,
                label: l10n.homeStatRecalls,
              ),
            ),
          ],
        ),
      ),
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
