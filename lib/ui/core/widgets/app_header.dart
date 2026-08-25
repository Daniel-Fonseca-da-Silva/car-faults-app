import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';
import 'brand_wordmark.dart';

/// Top bar shared by every screen: brand logo + wordmark on the left,
/// account avatar on the right.
///
/// The avatar is only interactive when [onAvatarTap] is given; on the login
/// screen it stays decorative.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, this.onAvatarTap});

  final VoidCallback? onAvatarTap;

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
          const BrandWordmark(),
          const Spacer(),
          _avatar(l10n.appHeaderAvatar),
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

  Widget _avatar(String label) {
    return Semantics(
      label: label,
      button: onAvatarTap != null,
      child: InkWell(
        onTap: onAvatarTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: _minTouchTarget,
          height: _minTouchTarget,
          child: Center(
            child: CircleAvatar(
              backgroundColor: AppColors.surface,
              child: Icon(Icons.person, color: AppColors.muted),
            ),
          ),
        ),
      ),
    );
  }
}
