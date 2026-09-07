import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/favorites_repository.dart';
import 'data/repositories/garage_repository.dart';
import 'data/repositories/locale_repository.dart';
import 'data/repositories/lookup_repository.dart';
import 'data/repositories/platform_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/services/locale_preferences_service.dart';
import 'data/services/secure_token_storage.dart';
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

  // One shared token storage and `onUnauthorized` callback so a 401 from any
  // authenticated repository (Auth, Favorites, Garage, Profile) signs the
  // user out consistently.
  final tokenStorage = SecureTokenStorage();
  final authSessionViewModel = AuthSessionViewModel();
  final onUnauthorized = authSessionViewModel.signOut;

  final authRepository = AuthRepository(
    tokenStorage: tokenStorage,
    onUnauthorized: onUnauthorized,
  );
  final favoritesRepository = FavoritesRepository(
    tokenStorage: tokenStorage,
    onUnauthorized: onUnauthorized,
  );
  final garageRepository = GarageRepository(
    tokenStorage: tokenStorage,
    onUnauthorized: onUnauthorized,
  );
  final profileRepository = ProfileRepository(
    tokenStorage: tokenStorage,
    onUnauthorized: onUnauthorized,
  );

  final restoredUser = await authRepository.restoreSession();
  if (restoredUser != null) {
    authSessionViewModel.setUser(restoredUser);
  }

  runApp(
    CarFaultsApp(
      localeRepository: localeRepository,
      initialLocale: initialLocale,
      authRepository: authRepository,
      authSessionViewModel: authSessionViewModel,
      favoritesRepository: favoritesRepository,
      garageRepository: garageRepository,
      profileRepository: profileRepository,
    ),
  );
}

class CarFaultsApp extends StatelessWidget {
  CarFaultsApp({
    super.key,
    LocaleRepository? localeRepository,
    this.initialLocale = AppLocale.pt,
    AuthRepository? authRepository,
    AuthSessionViewModel? authSessionViewModel,
    LookupRepository? lookupRepository,
    PlatformRepository? platformRepository,
    ProfileRepository? profileRepository,
    GarageRepository? garageRepository,
    FavoritesRepository? favoritesRepository,
  }) : localeRepository =
           localeRepository ??
           LocaleRepository(service: LocalePreferencesService()),
       authRepository = authRepository ?? AuthRepository(),
       authSessionViewModel = authSessionViewModel ?? AuthSessionViewModel(),
       lookupRepository = lookupRepository ?? LookupRepository(),
       platformRepository = platformRepository ?? PlatformRepository(),
       profileRepository = profileRepository ?? ProfileRepository(),
       garageRepository = garageRepository ?? GarageRepository(),
       favoritesRepository = favoritesRepository ?? FavoritesRepository();

  final LocaleRepository localeRepository;
  final AppLocale initialLocale;
  final AuthRepository authRepository;
  final AuthSessionViewModel authSessionViewModel;
  final LookupRepository lookupRepository;
  final PlatformRepository platformRepository;
  final ProfileRepository profileRepository;
  final GarageRepository garageRepository;
  final FavoritesRepository favoritesRepository;

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
        ChangeNotifierProvider.value(value: authSessionViewModel),
        Provider.value(value: authRepository),
        Provider.value(value: lookupRepository),
        Provider.value(value: platformRepository),
        Provider.value(value: profileRepository),
        Provider.value(value: garageRepository),
        Provider.value(value: favoritesRepository),
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
