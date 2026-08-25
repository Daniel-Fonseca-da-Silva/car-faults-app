import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Single column of the login stats bar: orange value over a muted label.
class LoginStatItem extends StatelessWidget {
  const LoginStatItem({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$value $label',
      excludeSemantics: true,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
