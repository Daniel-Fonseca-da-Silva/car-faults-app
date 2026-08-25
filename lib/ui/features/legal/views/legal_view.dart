import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../view_models/legal_view_model.dart';
import 'widgets/legal_document_body.dart';
import 'widgets/legal_hero.dart';
import 'widgets/legal_section_nav.dart';

/// Full-screen privacy policy and terms of service.
///
/// Loads the bundled JSON for the active locale. When [initialSection] is
/// [LegalSectionTarget.terms], scrolls to the terms document after load.
class LegalView extends StatefulWidget {
  const LegalView({
    super.key,
    this.initialSection = LegalSectionTarget.privacy,
  });

  final LegalSectionTarget initialSection;

  @override
  State<LegalView> createState() => _LegalViewState();
}

class _LegalViewState extends State<LegalView> {
  final _privacyKey = GlobalKey();
  final _termsKey = GlobalKey();
  var _didScrollToInitial = false;
  String? _requestedLanguage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageCode = Localizations.localeOf(context).languageCode;
    if (_requestedLanguage == languageCode) return;
    _requestedLanguage = languageCode;
    _didScrollToInitial = false;
    final viewModel = context.read<LegalViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      viewModel.load(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.watch<LegalViewModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
      ),
      body: SafeArea(child: _body(context, viewModel, l10n)),
    );
  }

  Widget _body(
    BuildContext context,
    LegalViewModel viewModel,
    AppLocalizations l10n,
  ) {
    if (viewModel.isLoading && viewModel.content == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null && viewModel.content == null) {
      return _errorState(context, viewModel, l10n);
    }

    final content = viewModel.content;
    if (content == null) {
      return const Center(child: CircularProgressIndicator());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToInitialIfNeeded();
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LegalHero(
            eyebrow: content.heroEyebrow,
            title: content.heroTitle,
            imageAlt: content.heroImageAlt,
          ),
          const SizedBox(height: 16),
          LegalSectionNav(
            privacyLabel: content.navPrivacy,
            termsLabel: content.navTerms,
            onPrivacyTap: () => _scrollTo(_privacyKey),
            onTermsTap: () => _scrollTo(_termsKey),
          ),
          const SizedBox(height: 32),
          KeyedSubtree(
            key: _privacyKey,
            child: LegalDocumentBody(document: content.policy),
          ),
          const SizedBox(height: 40),
          KeyedSubtree(
            key: _termsKey,
            child: LegalDocumentBody(document: content.terms),
          ),
        ],
      ),
    );
  }

  Widget _errorState(
    BuildContext context,
    LegalViewModel viewModel,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.legalLoadError,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                final code = Localizations.localeOf(context).languageCode;
                viewModel.reload(code);
              },
              child: Text(l10n.legalRetry),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToInitialIfNeeded() {
    if (_didScrollToInitial) return;
    if (widget.initialSection != LegalSectionTarget.terms) {
      _didScrollToInitial = true;
      return;
    }
    final context = _termsKey.currentContext;
    if (context == null) return;
    _didScrollToInitial = true;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollTo(GlobalKey key) {
    final target = key.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
