import 'dart:async';

import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../features/about/views/about_view.dart';
import '../../features/garage/view_models/garage_view_model.dart';
import '../../features/garage/views/garage_view.dart';
import '../../features/login/views/login_view.dart';
import '../../features/profile/view_models/profile_view_model.dart';
import '../../features/profile/views/profile_view.dart';
import '../theme/app_colors.dart';
import '../view_models/auth_session_view_model.dart';
import 'app_nav_drawer_header.dart';
import 'app_nav_menu_item.dart';
import 'google_user_avatar.dart';

/// Right-side navigation drawer shared by every screen wrapped in
/// [AppScaffold]: sign-in/account, "Defeitos" (home), "Sobre", "Perfil" and
/// "Garagem".
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
            AppNavMenuItem(
              label: l10n.navProfile,
              onTap: () => _openProfile(context),
            ),
            AppNavMenuItem(
              label: l10n.navGarage,
              onTap: () => _openGarage(context),
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
    pushLoginView(context);
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

  void _openProfile(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider(
          create: (context) =>
              ProfileViewModel(authRepository: context.read<AuthRepository>()),
          child: const ProfileView(),
        ),
      ),
    );
  }

  void _openGarage(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => GarageViewModel(),
          child: const GarageView(),
        ),
      ),
    );
  }

  void _signOut(BuildContext context) {
    final authRepository = context.read<AuthRepository>();
    context.read<AuthSessionViewModel>().signOut();
    Navigator.of(context).pop();
    unawaited(authRepository.signOut());
  }
}
