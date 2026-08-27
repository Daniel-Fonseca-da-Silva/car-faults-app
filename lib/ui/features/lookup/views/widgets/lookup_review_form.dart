import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../lookup_demo_display.dart';
import 'lookup_star_rating.dart';

/// Form to rate a [KnownIssue] as the demo user (Ana Silva): star picker,
/// optional comment and a submit button, disabled until a star is picked.
class LookupReviewForm extends StatefulWidget {
  const LookupReviewForm({super.key, required this.onSubmit});

  /// Called with the chosen rating and a trimmed, non-empty comment (or
  /// `null` when left blank).
  final void Function(int rating, String? comment) onSubmit;

  @override
  State<LookupReviewForm> createState() => _LookupReviewFormState();
}

class _LookupReviewFormState extends State<LookupReviewForm> {
  final _commentController = TextEditingController();
  var _rating = 0;

  static const _avatarRadius = 16.0;
  static const _commentLines = 2;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: _avatarRadius,
              backgroundColor: AppColors.primary,
              child: Text(
                LookupDemoDisplay.currentUserInitials,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.lookupReviewsYourRating.toUpperCase(),
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
        LookupStarRating(
          value: _rating.toDouble(),
          onChanged: (value) => setState(() => _rating = value),
        ),
        const SizedBox(height: 12),
        AppTextField(
          hintText: l10n.lookupReviewsCommentHint,
          controller: _commentController,
          minLines: _commentLines,
          maxLines: _commentLines,
        ),
        const SizedBox(height: 12),
        AppPrimaryButton(
          label: l10n.lookupReviewsSubmit,
          onPressed: _rating > 0 ? _submit : null,
        ),
      ],
    );
  }

  void _submit() {
    final comment = _commentController.text.trim();
    widget.onSubmit(_rating, comment.isEmpty ? null : comment);
  }
}
