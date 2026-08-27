import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/locale_repository.dart';
import 'data/services/locale_preferences_service.dart';
import 'domain/models/app_locale.dart';
import 'ui/core/constants/app_brand.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/core/view_models/auth_session_view_model.dart';
import 'ui/core/view_models/locale_view_model.dart';
import 'ui/features/home/views/home_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localeRepository = LocaleRepository(
    service: LocalePreferencesService(),
  );
  final initialLocale = await localeRepository.load();

  runApp(
    CarFaultsApp(
      localeRepository: localeRepository,
      initialLocale: initialLocale,
    ),
  );
}

class CarFaultsApp extends StatelessWidget {
  CarFaultsApp({
    super.key,
    LocaleRepository? localeRepository,
    this.initialLocale = AppLocale.pt,
  }) : localeRepository =
           localeRepository ??
           LocaleRepository(service: LocalePreferencesService());

  final LocaleRepository localeRepository;
  final AppLocale initialLocale;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LocaleViewModel(
            repository: localeRepository,
            initialLocale: initialLocale,
          ),
        ),
        ChangeNotifierProvider(create: (_) => AuthSessionViewModel()),
      ],
      child: Consumer<LocaleViewModel>(
        builder: (context, localeViewModel, _) {
          return MaterialApp(
            title: AppBrand.displayName,
            theme: AppTheme.dark,
            debugShowCheckedModeBanner: false,
            locale: localeViewModel.locale.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeView(),
          );
        },
      ),
    );
  }
}
