import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../view_models/login_view_model.dart';

/// "Não tem conta? Cadastre-se grátis" prompt below the Google button.
///
/// Sign-up and sign-in are the same OAuth command — Google decides whether
/// the account already exists.
class LoginSignUpPrompt extends StatelessWidget {
  const LoginSignUpPrompt({super.key, required this.viewModel});

  final LoginViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: [
            Text(
              l10n.loginNoAccount,
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
            ),
            GestureDetector(
              onTap: viewModel.isSigningIn
                  ? null
                  : viewModel.continueWithGoogle,
              child: Semantics(
                button: true,
                label: l10n.loginSignUp,
                child: Text(
                  l10n.loginSignUp,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
