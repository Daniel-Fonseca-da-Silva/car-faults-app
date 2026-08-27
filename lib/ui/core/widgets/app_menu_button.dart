import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Square hamburger button that opens the parent [Scaffold]'s end drawer.
class AppMenuButton extends StatelessWidget {
  const AppMenuButton({super.key});

  static const _size = 48.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      label: l10n.navMenuOpen,
      button: true,
      child: InkWell(
        onTap: () => Scaffold.of(context).openEndDrawer(),
        borderRadius: BorderRadius.circular(8),
        child: const SizedBox(
          width: _size,
          height: _size,
          child: Icon(Icons.menu, color: AppColors.onSurface),
        ),
      ),
    );
  }
}
