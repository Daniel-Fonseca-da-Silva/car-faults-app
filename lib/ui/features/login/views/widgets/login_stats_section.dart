import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../login_stats_display.dart';
import 'login_stat_item.dart';

/// Static stats bar below the sign-up prompt: faults, models and recalls.
///
/// Values come from [LoginStatsDisplay] — this slice does not call the API.
class LoginStatsSection extends StatelessWidget {
  const LoginStatsSection({super.key});

  static const _horizontalRule = BorderSide(color: AppColors.surface);
  static const _columnDividerWidth = 1.0;
  static const _columnDividerHeight = 32.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      container: true,
      label: l10n.loginStatsSemanticLabel,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          border: Border(top: _horizontalRule, bottom: _horizontalRule),
        ),
        child: Row(
          children: [
            Expanded(
              child: LoginStatItem(
                value: LoginStatsDisplay.faultsValue,
                label: l10n.loginStatFaults,
              ),
            ),
            _columnDivider(),
            Expanded(
              child: LoginStatItem(
                value: LoginStatsDisplay.modelsValue,
                label: l10n.loginStatModels,
              ),
            ),
            _columnDivider(),
            Expanded(
              child: LoginStatItem(
                value: LoginStatsDisplay.recallsValue,
                label: l10n.loginStatRecalls,
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
