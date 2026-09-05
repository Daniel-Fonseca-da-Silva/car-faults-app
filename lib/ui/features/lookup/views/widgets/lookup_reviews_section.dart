import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/repositories/community_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/relative_time.dart';
import '../../../../core/utils/require_sign_in.dart';
import '../../../../core/view_models/auth_session_view_model.dart';
import '../../view_models/lookup_results_view_model.dart';
import 'lookup_review_form.dart';
import 'lookup_review_item.dart';
import 'lookup_star_rating.dart';

/// "AVALIAR ESTE DEFEITO" section inside an expanded [LookupIssueCard]:
/// average rating + review list when there are any, otherwise an empty
/// state or a loading indicator while the reviews are being fetched, and
/// [LookupReviewForm] unless the signed-in user already reviewed it.
class LookupReviewsSection extends StatelessWidget {
  const LookupReviewsSection({super.key, required this.issueId});

  final String issueId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.watch<LookupResultsViewModel>();
    final currentUserId = context.watch<AuthSessionViewModel>().user?.id;
    final reviews = viewModel.reviewsFor(issueId);
    final average = viewModel.averageFor(issueId);
    final hasOwnReview = viewModel.hasOwnReview(issueId, currentUserId);
    final isLoading = viewModel.isLoadingReviews(issueId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star_border, color: AppColors.primary, size: 16),
            const SizedBox(width: 6),
            Text(
              l10n.lookupReviewsTitle.toUpperCase(),
              style: const TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          )
        else if (reviews.isEmpty)
          Text(
            l10n.lookupReviewsEmpty,
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          )
        else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                average!.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
              const SizedBox(width: 8),
              LookupStarRating(value: average),
            ],
          ),
          Text(
            l10n.lookupReviewsCount(reviews.length),
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          for (final review in reviews)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: LookupReviewItem(
                initials: review.initials,
                userName: review.userName,
                rating: review.rating,
                comment: review.comment,
                submittedAgo: relativeTimeLabel(review.submittedAt, l10n),
                isOwner: review.userId == currentUserId,
              ),
            ),
        ],
        if (!hasOwnReview) ...[
          const SizedBox(height: 12),
          LookupReviewForm(
            onSubmit: (rating, comment) => requireSignIn(context, () async {
              final result = await context
                  .read<LookupResultsViewModel>()
                  .submitReview(
                    issueId: issueId,
                    rating: rating,
                    comment: comment,
                  );
              if (!context.mounted) return;

              final message = switch (result) {
                SubmitReviewSuccess() => null,
                SubmitReviewDuplicate() => l10n.lookupReviewsDuplicateError,
                SubmitReviewFailure() => l10n.lookupReviewsSubmitError,
              };
              if (message != null) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(message)));
              }
            }),
          ),
        ],
      ],
    );
  }
}
