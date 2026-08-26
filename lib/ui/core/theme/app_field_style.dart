import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Visuals shared by `AppTextField` and `AppDropdownField` so both inputs look
/// identical inside a card.
abstract final class AppFieldStyle {
  static const minHeight = 48.0;
  static const borderRadius = 8.0;
  static const fill = AppColors.background;
  static const _horizontalPadding = 12.0;
  static const contentPadding = EdgeInsets.symmetric(
    horizontal: _horizontalPadding,
    vertical: 14,
  );
  static const boxPadding = EdgeInsets.symmetric(
    horizontal: _horizontalPadding,
  );

  static const textStyle = TextStyle(color: AppColors.onSurface, fontSize: 14);
  static const hintStyle = TextStyle(color: AppColors.muted, fontSize: 14);

  static BorderSide get borderSide =>
      BorderSide(color: AppColors.muted.withValues(alpha: 0.25));

  static OutlineInputBorder get inputBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(borderRadius),
    borderSide: borderSide,
  );

  static BoxDecoration get boxDecoration => BoxDecoration(
    color: fill,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.fromBorderSide(borderSide),
  );
}
