import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../domain/models/profile_snapshot.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/google_user_avatar.dart';

/// Summary card at the top of the profile screen: avatar with an online
/// indicator, name, email and a "member since" pill.
class ProfileIdentityCard extends StatelessWidget {
  const ProfileIdentityCard({super.key, required this.snapshot});

  final ProfileSnapshot snapshot;

  static const _borderRadius = 14.0;
  static const _padding = 20.0;
  static const _avatarSize = 64.0;
  static const _onlineDotSize = 14.0;
  static const _borderOpacity = 0.25;
  static const _gradientOpacity = 0.12;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final user = snapshot.user;
    final memberSince = DateFormat.yMMMM(locale).format(snapshot.createdAt);

    return Container(
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: _borderOpacity),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: _gradientOpacity),
            AppColors.surface,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  GoogleUserAvatar(
                    name: user.name,
                    photoUrl: user.photoUrl,
                    size: _avatarSize,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Semantics(
                      label: l10n.profileOnlineStatus,
                      child: Container(
                        width: _onlineDotSize,
                        height: _onlineDotSize,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  l10n.profileMemberSince(memberSince),
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
