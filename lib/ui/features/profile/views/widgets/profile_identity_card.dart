import 'package:car_faults_app/domain/models/profile_snapshot.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/google_user_avatar.dart';

/// Summary card at the top of the profile screen: avatar with online status,
/// name, email and a "member since" pill.
///
/// Static UI only in this slice: [snapshot] comes from
/// `ProfileDemoDisplay`, not a ViewModel or account backend.
class ProfileIdentityCard extends StatelessWidget {
  const ProfileIdentityCard({super.key, required this.snapshot});

  final ProfileSnapshot snapshot;

  static const _cardRadius = 14.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = snapshot.user;
    final memberSince = DateFormat.yMMMM(
      Localizations.localeOf(context).toString(),
    ).format(snapshot.createdAt);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Band(name: user.name, photoUrl: user.photoUrl),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 12),
                _MemberSincePill(label: l10n.profileMemberSince(memberSince)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Top strip of the card: a discreet diagonal gradient with the avatar and
/// its online status dot.
class _Band extends StatelessWidget {
  const _Band({required this.name, required this.photoUrl});

  final String name;
  final String? photoUrl;

  static const _height = 108.0;
  static const _avatarSize = 64.0;
  static const _statusDotSize = 14.0;
  static const _statusDotBorderWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: _height,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.16),
            AppColors.surface,
          ],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GoogleUserAvatar(name: name, photoUrl: photoUrl, size: _avatarSize),
          Positioned(
            right: -2,
            bottom: -2,
            child: Semantics(
              label: l10n.profileOnlineStatus,
              child: Container(
                width: _statusDotSize,
                height: _statusDotSize,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface,
                    width: _statusDotBorderWidth,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill showing the localized account creation month and year.
class _MemberSincePill extends StatelessWidget {
  const _MemberSincePill({required this.label});

  final String label;

  static const _radius = 999.0;
  static const _iconSize = 14.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          const Icon(Icons.verified, color: AppColors.primary, size: _iconSize),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
