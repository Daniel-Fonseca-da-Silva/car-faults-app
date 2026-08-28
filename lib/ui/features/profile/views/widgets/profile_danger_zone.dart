import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../view_models/profile_view_model.dart';

/// "ZONA DE RISCO" card: warns about permanent data loss and offers the
/// account-deletion action, gated behind a confirmation dialog.
class ProfileDangerZone extends StatelessWidget {
  const ProfileDangerZone({super.key, required this.viewModel});

  final ProfileViewModel viewModel;

  static const _borderRadius = 14.0;
  static const _padding = 20.0;
  static const _borderOpacity = 0.4;
  static const _backgroundOpacity = 0.08;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        color: AppColors.critical.withValues(alpha: _backgroundOpacity),
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color: AppColors.critical.withValues(alpha: _borderOpacity),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_outlined,
                color: AppColors.critical,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.profileDangerTitle.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.critical,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.profileDeleteAccount,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.profileDeleteAccountDescription,
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => _confirmDelete(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.critical,
                side: const BorderSide(color: AppColors.critical),
              ),
              child: Text(l10n.profileDeleteAccount),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.profileDeleteConfirmTitle),
        content: Text(l10n.profileDeleteConfirmDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.profileDeleteConfirmCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.profileDeleteConfirmDelete,
              style: const TextStyle(color: AppColors.critical),
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await viewModel.deleteAccount();
    }
  }
}
