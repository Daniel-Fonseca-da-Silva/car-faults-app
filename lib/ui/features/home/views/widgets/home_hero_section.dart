import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/section_eyebrow.dart';

/// Hero block below the header: eyebrow, title with its highlighted word
/// in orange and a muted subtitle. No background image, unlike the login
/// hero.
///
/// Static UI only in this slice: no ViewModel, no external data.
class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({super.key});

  static const _subtitleMaxWidth = 320.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SectionEyebrow(
            text: l10n.homeHeroEyebrow,
            textColor: AppColors.onSurface,
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              style: const TextStyle(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 30,
                height: 1.15,
                letterSpacing: 0.5,
              ),
              children: [
                TextSpan(text: '${l10n.homeHeroTitleBeforeHighlight} '),
                TextSpan(
                  text: l10n.homeHeroTitleHighlight,
                  style: const TextStyle(color: AppColors.primary),
                ),
                TextSpan(text: ' ${l10n.homeHeroTitleAfterHighlight}'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _subtitleMaxWidth),
            child: Text(
              l10n.homeHeroSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
