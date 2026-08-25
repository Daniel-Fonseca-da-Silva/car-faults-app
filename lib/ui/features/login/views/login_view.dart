import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_header.dart';
import '../view_models/login_view_model.dart';
import 'widgets/login_access_section.dart';
import 'widgets/login_hero_section.dart';
import 'widgets/login_sign_up_prompt.dart';
import 'widgets/login_stats_section.dart';

/// Login screen: header, hero, Google access, sign-up prompt, stats and footer.
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<LoginViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            final result = viewModel.lastResult;
            if (result != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.loginGoogleSoon)));
                viewModel.acknowledgeResult();
              });
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  const AppHeader(),
                  const LoginHeroSection(),
                  LoginAccessSection(viewModel: viewModel),
                  LoginSignUpPrompt(viewModel: viewModel),
                  const LoginStatsSection(),
                  AppFooter(disclaimer: l10n.loginDisclaimer),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
