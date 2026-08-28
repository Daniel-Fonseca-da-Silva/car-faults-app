import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../domain/models/profile_snapshot.dart';
import '../../../../core/theme/app_colors.dart';
import 'profile_copy_id_button.dart';
import 'profile_info_row.dart';

/// "Informações da conta" card: email, created/updated dates and a
/// copyable account ID.
class ProfileAccountInfoCard extends StatelessWidget {
  const ProfileAccountInfoCard({super.key, required this.snapshot});

  final ProfileSnapshot snapshot;

  static const _borderRadius = 14.0;
  static const _padding = 20.0;
  static const _borderOpacity = 0.2;
  static const _dividerOpacity = 0.15;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMMMMd(locale);

    return Container(
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: _borderOpacity),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.profileAccountTitle.toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ProfileInfoRow(
            icon: Icons.mail_outline,
            label: l10n.profileEmail,
            value: snapshot.user.email,
          ),
          const SizedBox(height: 16),
          ProfileInfoRow(
            icon: Icons.calendar_today_outlined,
            label: l10n.profileCreatedAt,
            value: dateFormat.format(snapshot.createdAt),
          ),
          const SizedBox(height: 16),
          ProfileInfoRow(
            icon: Icons.schedule,
            label: l10n.profileUpdatedAt,
            value: dateFormat.format(snapshot.updatedAt),
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.muted.withValues(alpha: _dividerOpacity)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.profileAccountId.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    snapshot.user.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ProfileCopyIdButton(accountId: snapshot.user.id),
            ],
          ),
        ],
      ),
    );
  }
}
