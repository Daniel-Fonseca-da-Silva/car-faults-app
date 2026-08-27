import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../features/about/views/about_view.dart';
import '../../features/login/view_models/login_view_model.dart';
import '../../features/login/views/login_view.dart';
import '../theme/app_colors.dart';
import '../view_models/auth_session_view_model.dart';
import 'app_nav_drawer_header.dart';
import 'app_nav_menu_item.dart';
import 'google_user_avatar.dart';

/// Right-side navigation drawer shared by every screen wrapped in
/// [AppScaffold]: sign-in/account, "Defeitos" (home) and "Sobre".
class AppNavDrawer extends StatelessWidget {
  const AppNavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthSessionViewModel>().user;

    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppNavDrawerHeader(title: l10n.navMenu),
            if (user == null)
              AppNavMenuItem(
                icon: Icons.login,
                label: l10n.navSignIn,
                onTap: () => _openLogin(context),
              ),
            AppNavMenuItem(
              label: l10n.navDefects,
              onTap: () => _goToDefects(context),
            ),
            AppNavMenuItem(
              label: l10n.navAbout,
              onTap: () => _goToAbout(context),
            ),
            if (user != null) ...[
              const Spacer(),
              const Divider(color: AppColors.surface, height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GoogleUserAvatar(name: user.name, photoUrl: user.photoUrl),
                    const SizedBox(width: 12),
                    Text(
                      user.name.split(' ').first,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              AppNavMenuItem(
                icon: Icons.logout,
                label: l10n.navSignOut,
                onTap: () => _signOut(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openLogin(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => LoginViewModel(authRepository: AuthRepository()),
          child: const LoginView(),
        ),
      ),
    );
  }

  void _goToDefects(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.popUntil((route) => route.isFirst);
  }

  void _goToAbout(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const AboutView()));
  }

  void _signOut(BuildContext context) {
    context.read<AuthSessionViewModel>().signOut();
    Navigator.of(context).pop();
  }
}
