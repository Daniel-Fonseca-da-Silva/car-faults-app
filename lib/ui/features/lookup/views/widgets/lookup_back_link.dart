import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Back link at the top of [LookupResultsView]: a muted arrow and the
/// "Nova busca" label.
class LookupBackLink extends StatelessWidget {
  const LookupBackLink({super.key, required this.onPressed});

  final VoidCallback onPressed;

  static const _minTouchHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context)!.lookupNewSearch;

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minTouchHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back, color: AppColors.muted, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
