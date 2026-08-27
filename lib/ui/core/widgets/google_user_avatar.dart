import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Circular Google account photo, falling back to initials when [photoUrl]
/// is missing or fails to load.
class GoogleUserAvatar extends StatefulWidget {
  const GoogleUserAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.size = GoogleUserAvatar.defaultSize,
  });

  final String name;
  final String? photoUrl;

  /// Diameter of the avatar circle.
  final double size;

  static const defaultSize = 40.0;

  @override
  State<GoogleUserAvatar> createState() => _GoogleUserAvatarState();
}

class _GoogleUserAvatarState extends State<GoogleUserAvatar> {
  var _imageFailed = false;

  static const _initialsFontSizeFactor = 0.35;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showImage = widget.photoUrl != null && !_imageFailed;

    return Semantics(
      label: l10n.navAvatar(widget.name),
      image: true,
      child: CircleAvatar(
        radius: widget.size / 2,
        backgroundColor: AppColors.surface,
        backgroundImage: showImage ? NetworkImage(widget.photoUrl!) : null,
        onBackgroundImageError: showImage
            ? (_, _) => setState(() => _imageFailed = true)
            : null,
        child: showImage
            ? null
            : Text(
                _initials(widget.name),
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: widget.size * _initialsFontSizeFactor,
                ),
              ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';

    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }
}
