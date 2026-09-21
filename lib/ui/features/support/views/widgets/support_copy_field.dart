import 'dart:async';

import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// Labelled value row with a copy-to-clipboard button, mirroring the web
/// Support page's `CopyField` component (MBWay number, Wise link, Pix key).
class SupportCopyField extends StatefulWidget {
  const SupportCopyField({
    super.key,
    required this.label,
    required this.value,
    required this.copyLabel,
  });

  final String label;
  final String value;
  final String copyLabel;

  @override
  State<SupportCopyField> createState() => _SupportCopyFieldState();
}

class _SupportCopyFieldState extends State<SupportCopyField> {
  static const _feedbackDuration = Duration(seconds: 2);

  var _copied = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final accent = _copied ? AppColors.success : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.value,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 14,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: FilledButton(
              onPressed: _copy,
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: AppColors.background,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_copied ? Icons.check : Icons.copy_outlined, size: 16),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _copied ? l10n.supportCopied : widget.copyLabel,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    if (!mounted) return;
    setState(() => _copied = true);
    _resetTimer?.cancel();
    _resetTimer = Timer(_feedbackDuration, () {
      if (mounted) setState(() => _copied = false);
    });
  }
}
