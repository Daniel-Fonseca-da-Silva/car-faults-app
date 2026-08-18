import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// "AUTOCRÓNICA" wordmark: `AUTO` in a light neutral, `CRÓNICA` in brand orange.
///
/// Shared between the login header and the footer, so callers can tune
/// [fontSize] to fit either context.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.fontSize = 20});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      height: 1,
      letterSpacing: 0.2,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(
            text: 'AUTO',
            style: TextStyle(color: AppColors.onSurface),
          ),
          TextSpan(
            text: 'CRÓNICA',
            style: TextStyle(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
