import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../data/repositories/community_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/relative_time.dart';
import '../../../../core/utils/require_sign_in.dart';
import '../../../../core/view_models/auth_session_view_model.dart';
import '../../view_models/lookup_results_view_model.dart';
import 'lookup_comment_form.dart';
import 'lookup_comment_item.dart';

/// "COMENTÁRIOS DA COMUNIDADE" section inside an expanded [LookupIssueCard]:
/// comment list when there are any, otherwise an empty state or a loading
/// indicator while the comments are being fetched, and [LookupCommentForm]
/// so any signed-in user can add one (there's no per-user limit, unlike
/// reviews).
class LookupCommentsSection extends StatelessWidget {
  const LookupCommentsSection({super.key, required this.issueId});

  final String issueId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.watch<LookupResultsViewModel>();
    final currentUserId = context.watch<AuthSessionViewModel>().user?.id;
    final comments = viewModel.commentsFor(issueId);
    final isLoading = viewModel.isLoadingComments(issueId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              color: AppColors.primary,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              l10n.lookupCommentsTitle.toUpperCase(),
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
        else if (comments.isEmpty)
          Text(
            l10n.lookupCommentsEmpty,
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          )
        else
          for (final comment in comments)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: LookupCommentItem(
                initials: comment.initials,
                userName: comment.userName,
                body: comment.body,
                imageUrl: comment.imageUrl,
                submittedAgo: relativeTimeLabel(comment.submittedAt, l10n),
                isOwner: comment.userId == currentUserId,
              ),
            ),
        const SizedBox(height: 12),
        LookupCommentForm(
          onSubmit: (body, imageUrl) => requireSignIn(context, () async {
            final result = await context
                .read<LookupResultsViewModel>()
                .submitComment(
                  issueId: issueId,
                  body: body,
                  imageUrl: imageUrl,
                );
            if (!context.mounted) return;

            final message = switch (result) {
              SubmitCommentSuccess() => null,
              SubmitCommentFailure() => l10n.lookupCommentsSubmitError,
            };
            if (message != null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(message)));
            }
          }),
          pickAndUploadImage: () async {
            final picked = await ImagePicker().pickImage(
              source: ImageSource.gallery,
              imageQuality: 80,
            );
            if (picked == null || !context.mounted) return null;
            return context.read<LookupResultsViewModel>().uploadCommentImage(
              picked.path,
            );
          },
        ),
      ],
    );
  }
}
