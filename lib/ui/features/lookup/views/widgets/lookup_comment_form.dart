import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../lookup_demo_display.dart';

/// Form to comment on a [KnownIssue] as the demo user (Ana Silva): a body
/// field, an optional attached image and a submit button, disabled until
/// the body is non-empty.
///
/// [pickAndUploadImage] is called when the user taps "add photo"; it should
/// pick an image, upload it and resolve to the uploaded URL (or `null` if
/// the user cancelled or the upload failed). Passing `null` hides the
/// affordance entirely — used by tests that don't want to exercise the real
/// image picker.
class LookupCommentForm extends StatefulWidget {
  const LookupCommentForm({
    super.key,
    required this.onSubmit,
    this.pickAndUploadImage,
  });

  /// Called with the trimmed, non-empty body and the uploaded image URL (or
  /// `null` when no image was attached).
  final void Function(String body, String? imageUrl) onSubmit;

  final Future<String?> Function()? pickAndUploadImage;

  @override
  State<LookupCommentForm> createState() => _LookupCommentFormState();
}

class _LookupCommentFormState extends State<LookupCommentForm> {
  final _bodyController = TextEditingController();
  String? _imageUrl;
  var _isUploadingImage = false;

  static const _avatarRadius = 16.0;
  static const _bodyLines = 2;
  static const _thumbnailSize = 48.0;

  @override
  void initState() {
    super.initState();
    _bodyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canSubmit =
        _bodyController.text.trim().isNotEmpty && !_isUploadingImage;

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
              l10n.lookupCommentsYourComment.toUpperCase(),
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
        AppTextField(
          hintText: l10n.lookupCommentsHint,
          controller: _bodyController,
          minLines: _bodyLines,
          maxLines: _bodyLines,
        ),
        const SizedBox(height: 8),
        if (_imageUrl != null)
          _ImagePreview(
            url: _imageUrl!,
            size: _thumbnailSize,
            onRemove: () => setState(() => _imageUrl = null),
          )
        else if (widget.pickAndUploadImage != null)
          TextButton.icon(
            onPressed: _isUploadingImage ? null : _pickImage,
            icon: _isUploadingImage
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(Icons.image_outlined, size: 18),
            label: Text(l10n.lookupCommentsAddImage),
          ),
        const SizedBox(height: 12),
        AppPrimaryButton(
          label: l10n.lookupCommentsSubmit,
          onPressed: canSubmit ? _submit : null,
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final pickAndUploadImage = widget.pickAndUploadImage;
    if (pickAndUploadImage == null) return;

    setState(() => _isUploadingImage = true);
    final url = await pickAndUploadImage();
    if (!mounted) return;

    setState(() {
      _isUploadingImage = false;
      if (url != null) _imageUrl = url;
    });
  }

  void _submit() {
    final body = _bodyController.text.trim();
    if (body.isEmpty) return;

    widget.onSubmit(body, _imageUrl);
    _bodyController.clear();
    setState(() => _imageUrl = null);
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.url,
    required this.size,
    required this.onRemove,
  });

  final String url;
  final double size;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => SizedBox(width: size, height: size),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.muted, size: 18),
          onPressed: onRemove,
        ),
      ],
    );
  }
}
