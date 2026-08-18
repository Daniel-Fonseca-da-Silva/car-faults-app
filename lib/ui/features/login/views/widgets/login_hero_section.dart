import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/section_eyebrow.dart';

/// Hero block below the header: garage photo, gradient overlay, brand
/// eyebrow and title with its highlighted word in orange.
///
/// Static UI only in this slice: no ViewModel, no Google access.
class LoginHeroSection extends StatelessWidget {
  const LoginHeroSection({super.key});

  static const _heightFactor = 0.45;
  static const _overlayMidStop = 0.55;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final height = MediaQuery.sizeOf(context).height * _heightFactor;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Semantics(
            label: l10n.loginHeroImageAlt,
            image: true,
            child: Image.asset(AppAssets.garage, fit: BoxFit.cover),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, _overlayMidStop, 1],
                colors: [
                  AppColors.background.withValues(alpha: 0),
                  AppColors.background.withValues(alpha: 0.5),
                  AppColors.background,
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SectionEyebrow(text: l10n.loginHeroEyebrow),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                      height: 1.15,
                    ),
                    children: [
                      TextSpan(text: '${l10n.loginHeroTitleBeforeHighlight} '),
                      TextSpan(
                        text: l10n.loginHeroTitleHighlight,
                        style: const TextStyle(color: AppColors.primary),
                      ),
                      TextSpan(text: ' ${l10n.loginHeroTitleAfterHighlight}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
