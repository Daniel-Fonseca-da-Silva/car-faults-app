import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_brand.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';

/// "About" screen: founder photo and intro, three copy sections mirroring
/// the web app's `/about` page, and a closing CTA back to the home (vehicle
/// lookup) screen — this app has no `/defects` hub to link to instead.
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _intro(l10n),
            const SizedBox(height: 32),
            _section(
              title: l10n.aboutProblemTitle,
              body: l10n.aboutProblemBody,
            ),
            const SizedBox(height: 24),
            _section(
              title: l10n.aboutSolutionTitle,
              body: l10n.aboutSolutionBody,
            ),
            const SizedBox(height: 24),
            _section(
              title: l10n.aboutCommunityTitle,
              body: l10n.aboutCommunityBody,
            ),
            const SizedBox(height: 32),
            const Divider(color: AppColors.surface, height: 1),
            const SizedBox(height: 24),
            _cta(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _intro(AppLocalizations l10n) {
    return Column(
      children: [
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
        const SizedBox(height: 20),
        Text(
          l10n.aboutTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.aboutLead,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 15,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _openLinkedin,
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 48),
            foregroundColor: AppColors.primary,
          ),
          child: Text(
            l10n.aboutLinkedinLabel,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _section({required String title, required String body}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 14,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _cta(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: () => _goHome(context),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(l10n.aboutCtaLabel),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.aboutCtaHint,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    );
  }

  Future<void> _openLinkedin() async {
    final uri = Uri.parse(AppBrand.founderLinkedinUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
