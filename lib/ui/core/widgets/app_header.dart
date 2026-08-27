import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';
import 'app_menu_button.dart';
import 'brand_wordmark.dart';
import 'locale_switcher.dart';

/// Top bar shared by every screen: brand logo + wordmark on the left,
/// language switcher and hamburger menu on the right.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  static const _logoSize = 32.0;
  static const _minTouchTarget = 48.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: const BoxConstraints(minHeight: _minTouchTarget),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.background,
      child: Row(
        children: [
          _logo(l10n.appHeaderLogo),
          const SizedBox(width: 8),
          const Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: BrandWordmark(fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
          const LocaleSwitcher(),
          const SizedBox(width: 8),
          const AppMenuButton(),
        ],
      ),
    );
  }

  Widget _logo(String label) {
    return Semantics(
      label: label,
      image: true,
      child: Image.asset(
        AppAssets.logo,
        width: _logoSize,
        height: _logoSize,
        fit: BoxFit.contain,
      ),
    );
  }
}
