import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/google_sign_in_button.dart';
import '../../../../core/widgets/section_eyebrow.dart';
import '../../view_models/login_view_model.dart';

/// "ACESSO" block below the hero: title, subtitle and the Google button.
///
/// No email/password fields — the API only exposes Google OAuth
/// (`GET /v1/auth/google`), which redirects to the web app.
class LoginAccessSection extends StatelessWidget {
  const LoginAccessSection({super.key, required this.viewModel});

  final LoginViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionEyebrow(text: l10n.loginAccessEyebrow),
          const SizedBox(height: 16),
          Text(
            l10n.loginAccessTitle,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.loginAccessSubtitle,
            style: const TextStyle(color: AppColors.muted, fontSize: 15),
          ),
          const SizedBox(height: 24),
          ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) => GoogleSignInButton(
              label: l10n.loginGoogle,
              isLoading: viewModel.isSigningIn,
              onPressed: viewModel.continueWithGoogle,
            ),
          ),
        ],
      ),
    );
  }
}
