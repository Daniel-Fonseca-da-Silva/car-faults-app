import 'package:car_faults_app/data/repositories/legal_repository.dart';
import 'package:car_faults_app/data/services/legal_document_service.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/legal/view_models/legal_view_model.dart';
import '../../features/legal/views/legal_view.dart';
import '../constants/app_brand.dart';
import '../theme/app_colors.dart';
import 'brand_wordmark.dart';

/// Bottom block shared by every screen: wordmark, data disclaimer, legal links
/// and copyright.
///
/// The [disclaimer] changes per screen, so the caller passes the localized
/// string. Legal links open [LegalView] via [Navigator.push].
class AppFooter extends StatelessWidget {
  const AppFooter({required this.disclaimer, super.key});

  final String disclaimer;

  static const _wordmarkFontSize = 16.0;
  static const _disclaimerFontSize = 12.0;
  static const _copyrightFontSize = 11.0;
  static const _minTouchHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        children: [
          const BrandWordmark(fontSize: _wordmarkFontSize),
          const SizedBox(height: 16),
          _mutedText(disclaimer, _disclaimerFontSize),
          const SizedBox(height: 12),
          _legalLinks(context, l10n),
          const SizedBox(height: 12),
          _mutedText(
            l10n.loginCopyright(AppBrand.copyrightYear),
            _copyrightFontSize,
          ),
        ],
      ),
    );
  }

  Widget _legalLinks(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legalLink(
          label: l10n.legalLinkPrivacy,
          onTap: () => _openLegal(context, LegalSectionTarget.privacy),
        ),
        const SizedBox(width: 24),
        _legalLink(
          label: l10n.legalLinkTerms,
          onTap: () => _openLegal(context, LegalSectionTarget.terms),
        ),
      ],
    );
  }

  Widget _legalLink({required String label, required VoidCallback onTap}) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minTouchHeight),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openLegal(BuildContext context, LegalSectionTarget section) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => LegalViewModel(
            repository: LegalRepository(service: LegalDocumentService()),
          ),
          child: LegalView(initialSection: section),
        ),
      ),
    );
  }

  Widget _mutedText(String value, double fontSize) {
    return Text(
      value,
      textAlign: TextAlign.center,
      style: TextStyle(color: AppColors.muted, fontSize: fontSize, height: 1.4),
    );
  }
}
