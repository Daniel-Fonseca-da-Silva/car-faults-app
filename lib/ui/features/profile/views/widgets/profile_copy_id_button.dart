import 'dart:async';

import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// Copy-to-clipboard button for the account ID shown in
/// [ProfileAccountInfoCard].
///
/// Local UI state only: after a tap it copies [accountId] and swaps its
/// icon/[Semantics] label to the "copied" state for [_feedbackDuration].
class ProfileCopyIdButton extends StatefulWidget {
  const ProfileCopyIdButton({super.key, required this.accountId});

  final String accountId;

  @override
  State<ProfileCopyIdButton> createState() => _ProfileCopyIdButtonState();
}

class _ProfileCopyIdButtonState extends State<ProfileCopyIdButton> {
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

    return Semantics(
      button: true,
      label: _copied ? l10n.profileCopied : l10n.profileCopyId,
      child: IconButton(
        onPressed: _copy,
        icon: Icon(
          _copied ? Icons.check : Icons.copy_outlined,
          color: _copied ? AppColors.success : AppColors.primary,
        ),
      ),
    );
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.accountId));
    if (!mounted) return;
    setState(() => _copied = true);
    _resetTimer?.cancel();
    _resetTimer = Timer(_feedbackDuration, () {
      if (mounted) setState(() => _copied = false);
    });
  }
}
