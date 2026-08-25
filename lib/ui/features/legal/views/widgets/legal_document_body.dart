import 'package:car_faults_app/domain/models/legal_content.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Renders one legal document: title, dates and the ordered sections.
class LegalDocumentBody extends StatelessWidget {
  const LegalDocumentBody({super.key, required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          document.title,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          document.effectiveDate,
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        Text(
          document.lastUpdated,
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 24),
        for (final section in document.sections) ...[
          Text(
            section.heading,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 17,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          for (final paragraph in section.paragraphs) ...[
            Text(
              paragraph,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 14,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
