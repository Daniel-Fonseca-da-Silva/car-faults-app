import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// One tappable row of [AppNavDrawer]: optional leading icon + label.
class AppNavMenuItem extends StatelessWidget {
  const AppNavMenuItem({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  static const _minHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.onSurface, size: 20),
                  const SizedBox(width: 12),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
