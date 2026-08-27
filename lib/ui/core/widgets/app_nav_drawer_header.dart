import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Title row of [AppNavDrawer]: the "Menu" title and a close button.
class AppNavDrawerHeader extends StatelessWidget {
  const AppNavDrawerHeader({super.key, required this.title});

  final String title;

  static const _minHeight = 56.0;
  static const _closeButtonSize = 48.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: const BoxConstraints(minHeight: _minHeight),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Semantics(
            button: true,
            label: l10n.navClose,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: _closeButtonSize,
                height: _closeButtonSize,
                child: Icon(Icons.close, color: AppColors.onSurface),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
