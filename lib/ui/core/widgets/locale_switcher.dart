import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/app_locale.dart';
import '../theme/app_colors.dart';
import '../view_models/locale_view_model.dart';
import 'locale_flag.dart';

/// Pill trigger + dropdown used to change the app's language.
///
/// Mirrors the web header's language switcher: flag, label, chevron, and a
/// checkmark on the active entry.
class LocaleSwitcher extends StatelessWidget {
  const LocaleSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final current = context.watch<LocaleViewModel>().locale;

    return Semantics(
      label: l10n.navLanguage,
      button: true,
      child: PopupMenuButton<AppLocale>(
        tooltip: l10n.navLanguage,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (locale) =>
            context.read<LocaleViewModel>().setLocale(locale),
        itemBuilder: (context) => [
          for (final locale in AppLocale.values)
            PopupMenuItem<AppLocale>(
              value: locale,
              child: _LocaleOption(
                locale: locale,
                label: _labelFor(l10n, locale),
                isActive: locale == current,
              ),
            ),
        ],
        child: _LocaleTrigger(locale: current),
      ),
    );
  }

  static String _labelFor(AppLocalizations l10n, AppLocale locale) =>
      switch (locale) {
        AppLocale.pt => l10n.localePt,
        AppLocale.en => l10n.localeEn,
        AppLocale.es => l10n.localeEs,
      };
}

class _LocaleTrigger extends StatelessWidget {
  const _LocaleTrigger({required this.locale});

  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LocaleFlag(locale: locale),
          const SizedBox(width: 6),
          Text(
            locale.languageCode.toUpperCase(),
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Icon(Icons.expand_more, color: AppColors.muted, size: 16),
        ],
      ),
    );
  }
}

class _LocaleOption extends StatelessWidget {
  const _LocaleOption({
    required this.locale,
    required this.label,
    required this.isActive,
  });

  final AppLocale locale;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LocaleFlag(locale: locale),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.onSurface),
          ),
        ),
        if (isActive)
          const Icon(Icons.check, color: AppColors.primary, size: 18),
      ],
    );
  }
}
