import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';

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
              SvgPicture.asset(
                AppAssets.googleLogo,
                width: _logoSize,
                height: _logoSize,
              ),
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
