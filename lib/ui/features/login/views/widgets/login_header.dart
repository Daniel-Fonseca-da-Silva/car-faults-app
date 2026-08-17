import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_brand.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_wordmark.dart';

/// Semantic labels for the header's icon-only elements.
///
/// English on purpose: full i18n (ARB) is introduced in a later slice.
abstract final class _LoginHeaderLabels {
  static const logo = AppBrand.logoSemanticLabel;
  static const avatar = 'Guest account';
}

/// Top bar of the login screen: brand logo + wordmark on the left,
/// guest avatar on the right.
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  static const _logoSize = 32.0;
  static const _minTouchHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: _minTouchHeight),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.background,
      child: Row(
        children: [
          Semantics(
            label: _LoginHeaderLabels.logo,
            image: true,
            child: Image.asset(
              AppAssets.logo,
              width: _logoSize,
              height: _logoSize,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 8),
          const BrandWordmark(),
          const Spacer(),
          Semantics(
            label: _LoginHeaderLabels.avatar,
            child: const CircleAvatar(
              backgroundColor: AppColors.surface,
              child: Icon(Icons.person, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}
