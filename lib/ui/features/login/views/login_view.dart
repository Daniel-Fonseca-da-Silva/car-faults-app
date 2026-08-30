import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../core/view_models/auth_session_view_model.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../view_models/login_view_model.dart';
import 'widgets/login_access_section.dart';
import 'widgets/login_hero_section.dart';
import 'widgets/login_sign_up_prompt.dart';

/// Pushes the login screen with its own [LoginViewModel], reusing the
/// app-wide [AuthRepository]. Callers can `await` the returned future to
/// know when the screen is popped, whether or not sign-in succeeded.
Future<void> pushLoginView(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ChangeNotifierProvider(
        create: (context) =>
            LoginViewModel(authRepository: context.read<AuthRepository>()),
        child: const LoginView(),
      ),
    ),
  );
}

/// Login screen: header, hero, Google access, sign-up prompt and footer.
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<LoginViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final result = viewModel.lastResult;
          if (result != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              _handleResult(context, l10n, viewModel, result);
            });
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const LoginHeroSection(),
                LoginAccessSection(viewModel: viewModel),
                LoginSignUpPrompt(viewModel: viewModel),
                AppFooter(disclaimer: l10n.loginDisclaimer),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleResult(
    BuildContext context,
    AppLocalizations l10n,
    LoginViewModel viewModel,
    AuthResult result,
  ) {
    switch (result) {
      case AuthSuccess(:final user):
        context.read<AuthSessionViewModel>().setUser(user);
        viewModel.acknowledgeResult();
        Navigator.of(context).pop();
      case AuthFailure(:final reason):
        viewModel.acknowledgeResult();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_failureMessage(l10n, reason))));
      case AuthComingSoon():
        viewModel.acknowledgeResult();
    }
  }

  String _failureMessage(AppLocalizations l10n, AuthFailureReason reason) {
    return switch (reason) {
      AuthFailureReason.network => l10n.loginGoogleErrorNetwork,
      AuthFailureReason.server ||
      AuthFailureReason.unknown => l10n.loginGoogleErrorGeneric,
    };
  }
}
