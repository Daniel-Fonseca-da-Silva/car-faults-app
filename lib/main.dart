import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/auth_repository.dart';
import 'ui/core/constants/app_brand.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/features/login/view_models/login_view_model.dart';
import 'ui/features/login/views/login_view.dart';

void main() {
  runApp(const CarFaultsApp());
}

class CarFaultsApp extends StatelessWidget {
  const CarFaultsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(authRepository: AuthRepository()),
      child: MaterialApp(
        title: AppBrand.displayName,
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LoginView(),
      ),
    );
  }
}
