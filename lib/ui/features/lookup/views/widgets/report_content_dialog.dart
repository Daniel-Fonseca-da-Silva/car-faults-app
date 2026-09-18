import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/models/report_reason.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Opens [_ReportContentDialog] and returns the chosen reason and optional
/// details, or `null` if the user cancelled.
Future<(ReportReason, String?)?> showReportContentDialog(BuildContext context) {
  return showDialog<(ReportReason, String?)>(
    context: context,
    builder: (context) => const _ReportContentDialog(),
  );
}

/// Reason picker + optional details field for reporting a comment or
/// review. Submit stays disabled until a reason is picked.
class _ReportContentDialog extends StatefulWidget {
  const _ReportContentDialog();

  @override
  State<_ReportContentDialog> createState() => _ReportContentDialogState();
}

class _ReportContentDialogState extends State<_ReportContentDialog> {
  final _detailsController = TextEditingController();
  ReportReason? _reason;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.lookupReportDialogTitle),
      content: SingleChildScrollView(
        child: RadioGroup<ReportReason>(
          groupValue: _reason,
          onChanged: (value) => setState(() => _reason = value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final reason in ReportReason.values)
                RadioListTile<ReportReason>(
                  value: reason,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                  title: Text(_reasonLabel(l10n, reason)),
                ),
              const SizedBox(height: 8),
              AppTextField(
                hintText: l10n.lookupReportDetailsHint,
                controller: _detailsController,
                minLines: 2,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.lookupReportCancel),
        ),
        TextButton(
          onPressed: _reason == null ? null : _submit,
          child: Text(l10n.lookupReportSubmit),
        ),
      ],
    );
  }

  void _submit() {
    final details = _detailsController.text.trim();
    Navigator.of(context).pop((_reason!, details.isEmpty ? null : details));
  }

  String _reasonLabel(AppLocalizations l10n, ReportReason reason) =>
      switch (reason) {
        ReportReason.spam => l10n.lookupReportReasonSpam,
        ReportReason.offensive => l10n.lookupReportReasonOffensive,
        ReportReason.inappropriatePhoto =>
          l10n.lookupReportReasonInappropriatePhoto,
        ReportReason.harassment => l10n.lookupReportReasonHarassment,
        ReportReason.other => l10n.lookupReportReasonOther,
      };
}
