import 'dart:async';

import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_support.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import 'widgets/support_amount_tile.dart';
import 'widgets/support_benefit_card.dart';
import 'widgets/support_copy_field.dart';
import 'widgets/support_qr_code.dart';

/// "Support" screen: founder photo and pitch, three benefit cards and a
/// donation card (MBWay, Wise and Pix), mirroring the web app's `/support`
/// page.
class SupportView extends StatelessWidget {
  const SupportView({super.key});

  static const _photoSize = 120.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _hero(l10n),
            const SizedBox(height: 32),
            _benefits(l10n),
            const SizedBox(height: 32),
            _donationCard(l10n),
          ],
        ),
      ),
    );
  }

  Widget _hero(AppLocalizations l10n) {
    return Column(
      children: [
        Semantics(
          label: l10n.supportPhotoAlt,
          image: true,
          child: ClipOval(
            child: Image.asset(
              AppAssets.supportFounderPhoto,
              width: _photoSize,
              height: _photoSize,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            l10n.supportBadge,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.supportTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.supportAuthorName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          l10n.supportAuthorRole,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.supportIntro,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _benefits(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.supportBenefitsTitle,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SupportBenefitCard(
          emoji: l10n.supportBenefitServersEmoji,
          title: l10n.supportBenefitServersTitle,
          body: l10n.supportBenefitServersBody,
        ),
        const SizedBox(height: 12),
        SupportBenefitCard(
          emoji: l10n.supportBenefitFeaturesEmoji,
          title: l10n.supportBenefitFeaturesTitle,
          body: l10n.supportBenefitFeaturesBody,
        ),
        const SizedBox(height: 12),
        SupportBenefitCard(
          emoji: l10n.supportBenefitCoffeeEmoji,
          title: l10n.supportBenefitCoffeeTitle,
          body: l10n.supportBenefitCoffeeBody,
        ),
      ],
    );
  }

  Widget _donationCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.supportDonationTitle,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.supportDonationBody,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SupportCopyField(
            label: l10n.supportNumberLabel,
            value: AppSupport.mbwayNumber,
            copyLabel: l10n.supportCopyNumber,
          ),
          _divider(),
          Text(
            l10n.supportInternationalTitle,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.supportInternationalBody,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: SupportQrCode(
              data: AppSupport.wisePayLink,
              semanticsLabel: l10n.supportWiseQrAlt,
            ),
          ),
          const SizedBox(height: 14),
          _CopyActionButton(
            value: AppSupport.wisePayLink,
            idleLabel: l10n.supportCopyLink,
            copiedLabel: l10n.supportCopied,
          ),
          const SizedBox(height: 10),
          SupportCopyField(
            label: l10n.supportWiseLinkLabel,
            value: AppSupport.wisePayLink,
            copyLabel: l10n.supportCopyLink,
          ),
          _divider(),
          Text(
            l10n.supportPixTitle,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.supportPixBody,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: SupportQrCode(
              data: AppSupport.pixBrCode,
              semanticsLabel: l10n.supportPixQrAlt,
            ),
          ),
          const SizedBox(height: 14),
          _CopyActionButton(
            value: AppSupport.pixBrCode,
            idleLabel: l10n.supportCopyPixCode,
            copiedLabel: l10n.supportCopied,
          ),
          const SizedBox(height: 10),
          SupportCopyField(
            label: l10n.supportPixKeyLabel,
            value: AppSupport.pixKey,
            copyLabel: l10n.supportCopyPixKey,
          ),
          _divider(),
          Text(
            l10n.supportAmountsTitle.toUpperCase(),
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SupportAmountTile(
                  emoji: l10n.supportAmountCoffeeEmoji,
                  amountLabel: l10n.supportAmountValue(2),
                  label: l10n.supportAmountCoffeeLabel,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SupportAmountTile(
                  emoji: l10n.supportAmountSnackEmoji,
                  amountLabel: l10n.supportAmountValue(5),
                  label: l10n.supportAmountSnackLabel,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SupportAmountTile(
                  emoji: l10n.supportAmountBoostEmoji,
                  amountLabel: l10n.supportAmountValue(10),
                  label: l10n.supportAmountBoostLabel,
                ),
              ),
            ],
          ),
          _divider(),
          Text(
            l10n.supportThanksTitle,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.supportThanksBody,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.supportSignature,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Divider(color: AppColors.muted.withValues(alpha: 0.15), height: 1),
    );
  }
}

/// Primary "copy to clipboard" button used by the Wise and Pix sections
/// (link and BR Code respectively): shows [idleLabel] until tapped, then a
/// checkmark + "Copiado!" for a couple of seconds.
class _CopyActionButton extends StatefulWidget {
  const _CopyActionButton({
    required this.value,
    required this.idleLabel,
    required this.copiedLabel,
  });

  final String value;
  final String idleLabel;
  final String copiedLabel;

  @override
  State<_CopyActionButton> createState() => _CopyActionButtonState();
}

class _CopyActionButtonState extends State<_CopyActionButton> {
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
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: FilledButton(
        onPressed: _copy,
        style: FilledButton.styleFrom(
          backgroundColor: _copied ? AppColors.success : AppColors.primary,
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_copied ? Icons.check : Icons.copy_outlined, size: 16),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _copied ? widget.copiedLabel : widget.idleLabel,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
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
