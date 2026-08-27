import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Row of 5 star icons.
///
/// Read-only when [onChanged] is `null`: [value] is rounded to the nearest
/// whole star (e.g. 4.3 shows as 4 filled + 1 outline). Interactive when
/// [onChanged] is set, with tap targets of at least 48dp for the form use
/// case.
class LookupStarRating extends StatelessWidget {
  const LookupStarRating({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 20,
  });

  final double value;
  final ValueChanged<int>? onChanged;
  final double size;

  static const _starCount = 5;
  static const _minTouchSize = 48.0;

  @override
  Widget build(BuildContext context) {
    final filled = value.round().clamp(0, _starCount);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 1; index <= _starCount; index++)
          _star(filled: index <= filled, index: index),
      ],
    );
  }

  Widget _star({required bool filled, required int index}) {
    final icon = Icon(
      filled ? Icons.star : Icons.star_border,
      color: AppColors.primary,
      size: size,
    );

    final onChanged = this.onChanged;
    if (onChanged == null) return icon;

    return IconButton(
      onPressed: () => onChanged(index),
      icon: icon,
      iconSize: size,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: _minTouchSize,
        minHeight: _minTouchSize,
      ),
    );
  }
}
