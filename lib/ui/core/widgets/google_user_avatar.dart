import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Circular Google account photo, falling back to initials when [photoUrl]
/// is missing or fails to load.
class GoogleUserAvatar extends StatefulWidget {
  const GoogleUserAvatar({super.key, required this.name, this.photoUrl});

  final String name;
  final String? photoUrl;

  static const size = 40.0;

  @override
  State<GoogleUserAvatar> createState() => _GoogleUserAvatarState();
}

class _GoogleUserAvatarState extends State<GoogleUserAvatar> {
  var _imageFailed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showImage = widget.photoUrl != null && !_imageFailed;

    return Semantics(
      label: l10n.navAvatar(widget.name),
      image: true,
      child: CircleAvatar(
        radius: GoogleUserAvatar.size / 2,
        backgroundColor: AppColors.surface,
        backgroundImage: showImage ? NetworkImage(widget.photoUrl!) : null,
        onBackgroundImageError: showImage
            ? (_, _) => setState(() => _imageFailed = true)
            : null,
        child: showImage
            ? null
            : Text(
                _initials(widget.name),
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
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
