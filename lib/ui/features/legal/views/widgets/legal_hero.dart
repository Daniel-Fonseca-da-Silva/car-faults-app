import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/section_eyebrow.dart';

/// Hero block at the top of the legal screen: Fiat photo, gradient, eyebrow
/// and title — same visual pattern as the login hero.
class LegalHero extends StatelessWidget {
  const LegalHero({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.imageAlt,
  });

  final String eyebrow;
  final String title;
  final String imageAlt;

  static const _height = 220.0;
  static const _overlayMidStop = 0.55;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Semantics(
              label: imageAlt,
              image: true,
              child: Image.asset(AppAssets.privacyHero, fit: BoxFit.cover),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, _overlayMidStop, 1],
                  colors: [
                    AppColors.background.withValues(alpha: 0.1),
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
                  SectionEyebrow(text: eyebrow),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
