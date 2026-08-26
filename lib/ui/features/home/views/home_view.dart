import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../core/widgets/app_footer.dart';
import '../../../core/widgets/app_header.dart';
import '../../login/view_models/login_view_model.dart';
import '../../login/views/login_view.dart';
import 'widgets/home_hero_section.dart';
import 'widgets/home_search_card.dart';
import 'widgets/home_stats_section.dart';

/// Home screen: shared header, hero, vehicle search card, stats bar and
/// shared footer. Reported faults arrive in a following slice.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppHeader(onAvatarTap: () => _openLogin(context)),
              const SizedBox(height: 24),
              const HomeHeroSection(),
              const SizedBox(height: 24),
              const HomeSearchCard(),
              const HomeStatsSection(),
              AppFooter(disclaimer: l10n.homeDisclaimer),
            ],
          ),
        ),
      ),
    );
  }

  void _openLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => LoginViewModel(authRepository: AuthRepository()),
          child: const LoginView(),
        ),
      ),
    );
  }
}
