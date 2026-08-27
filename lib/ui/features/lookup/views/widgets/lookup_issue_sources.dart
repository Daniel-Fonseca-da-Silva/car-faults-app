import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// "FONTES" label followed by the [KnownIssue.sources] URLs.
///
/// The URLs are plain, non-tappable text in this slice; `url_launcher` is
/// not a requirement yet.
class LookupIssueSources extends StatelessWidget {
  const LookupIssueSources({super.key, required this.sources});

  final List<String> sources;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.lookupSources.toUpperCase(),
          style: const TextStyle(
            color: AppColors.muted,
            fontWeight: FontWeight.w600,
            fontSize: 11,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        for (final source in sources)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Semantics(
              link: true,
              label: source,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.link, color: AppColors.primary, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      source,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
