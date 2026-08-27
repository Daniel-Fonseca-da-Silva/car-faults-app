import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'lookup_star_rating.dart';

/// One community review inside [LookupReviewsSection]: avatar, name, star
/// rating, relative time and an optional comment.
///
/// Shows the "a tua avaliação" badge when [isOwner] is `true`.
class LookupReviewItem extends StatelessWidget {
  const LookupReviewItem({
    super.key,
    required this.initials,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.submittedAgo,
    required this.isOwner,
  });

  final String initials;
  final String userName;
  final int rating;
  final String comment;
  final String submittedAgo;
  final bool isOwner;

  static const _avatarRadius = 16.0;
  static const _borderRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: isOwner ? 0.4 : 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: _avatarRadius,
                backgroundColor: AppColors.primary,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  userName,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isOwner) _OwnerBadge(text: l10n.lookupReviewsYourBadge),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              LookupStarRating(value: rating.toDouble(), size: 16),
              if (submittedAgo.isNotEmpty) ...[
                const Spacer(),
                Text(
                  submittedAgo,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              comment,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _OwnerBadge extends StatelessWidget {
  const _OwnerBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
