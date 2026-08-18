import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Orange dash + uppercase label used to introduce a section, e.g. the
/// login hero's brand mark or the Google access block's `ACESSO` title.
class SectionEyebrow extends StatelessWidget {
  const SectionEyebrow({super.key, required this.text});

  final String text;

  static const _dashWidth = 24.0;
  static const _dashHeight = 2.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _dashWidth,
          height: _dashHeight,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
