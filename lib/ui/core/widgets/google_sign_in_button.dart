import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Google's brand blue, used for the compact "G" mark on [GoogleSignInButton].
///
/// No Google logo asset ships with the app (native `google_sign_in` is out
/// of scope for this slice), so the mark is a plain colored "G" rather than
/// the official multi-color logotype.
const _googleBlue = Color(0xFF4285F4);

/// Full-width outlined button used for the login screen's only auth CTA.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  static const _minHeight = 48.0;
  static const _logoSize = 20.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(_minHeight),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          backgroundColor: AppColors.surface,
          disabledBackgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.muted),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: _logoSize,
                height: _logoSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.onSurface,
                ),
              )
            else
              const _GoogleMark(size: _logoSize),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Text(
        'G',
        style: TextStyle(
          color: _googleBlue,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.62,
          height: 1,
        ),
      ),
    );
  }
}
