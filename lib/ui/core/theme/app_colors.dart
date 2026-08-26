import 'package:flutter/material.dart';

/// Palette aligned with the web app's dark theme (`car-faults-web/app/globals.css`).
abstract final class AppColors {
  static const background = Color(0xFF1A1714);
  static const surface = Color(0xFF272220);
  static const primary = Color(0xFFE07830);
  static const onSurface = Color(0xFFF2EAE3);
  static const muted = Color(0xFFB0A296);

  /// Green of the "database online" indicator. The `ColorScheme` has no green,
  /// so the token lives here.
  static const success = Color(0xFF4CAF7D);
}
