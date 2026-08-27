import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';

/// Minimal "About" screen: title and the founder's photo.
class AboutView extends StatelessWidget {
  const AboutView({super.key});

  static const _photoSize = 120.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              l10n.aboutTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            Semantics(
              label: l10n.aboutFounderPhoto,
              image: true,
              child: ClipOval(
                child: Image.asset(
                  AppAssets.aboutFounderPhoto,
                  width: _photoSize,
                  height: _photoSize,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
