import 'package:car_faults_app/data/repositories/auth_repository.dart';
import 'package:car_faults_app/data/repositories/favorites_repository.dart';
import 'package:car_faults_app/data/repositories/garage_repository.dart';
import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/repositories/platform_repository.dart';
import 'package:car_faults_app/data/repositories/profile_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/domain/models/app_locale.dart';
import 'package:car_faults_app/domain/models/favorite_vehicle.dart';
import 'package:car_faults_app/domain/models/known_issue.dart';
import 'package:car_faults_app/domain/models/profile_snapshot.dart';
import 'package:car_faults_app/domain/models/saved_vehicle.dart';
import 'package:car_faults_app/domain/models/top_faults_page.dart';
import 'package:car_faults_app/domain/models/user.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/core/widgets/app_menu_button.dart';
import 'package:car_faults_app/ui/core/widgets/app_scaffold.dart';
import 'package:car_faults_app/ui/core/widgets/google_user_avatar.dart';
import 'package:car_faults_app/ui/features/about/views/about_view.dart';
import 'package:car_faults_app/ui/features/defects/views/defects_view.dart';
import 'package:car_faults_app/ui/features/favorites/views/favorites_view.dart';
import 'package:car_faults_app/ui/features/garage/views/garage_view.dart';
import 'package:car_faults_app/ui/features/login/views/login_view.dart';
import 'package:car_faults_app/ui/features/profile/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const _user = User(
  id: 'u1',
  name: 'Daniel Fonseca',
  email: 'daniel@example.com',
);

const _homeBody = 'home body';

class _FakeProfileRepository extends ProfileRepository {
  @override
  Future<ProfileSnapshot?> fetchSnapshot({required AppLocale locale}) async =>
      null;
}

class _FakeGarageRepository extends GarageRepository {
  @override
  Future<List<SavedVehicle>?> fetchVehicles({
    required AppLocale locale,
  }) async => const [];

  @override
  Future<List<KnownIssue>?> fetchKnownIssues(
    String vehicleId, {
    required AppLocale locale,
  }) async => const [];
}

class _FakeFavoritesRepository extends FavoritesRepository {
  @override
  Future<List<FavoriteVehicle>?> fetchFavorites({int? limit}) async => const [];
}

class _FakePlatformRepository extends PlatformRepository {
  @override
  Future<TopFaultsPage> getTopFaultsPage({
    required AppLocale locale,
    int limit = 20,
    String? cursor,
  }) async => const TopFaultsPage(items: [], nextCursor: null);
}

Widget _app({AuthSessionViewModel? session}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => LocaleViewModel(
          repository: LocaleRepository(service: LocalePreferencesService()),
        ),
      ),
      ChangeNotifierProvider.value(value: session ?? AuthSessionViewModel()),
      Provider<AuthRepository>.value(value: AuthRepository()),
      Provider<ProfileRepository>.value(value: _FakeProfileRepository()),
      Provider<GarageRepository>.value(value: _FakeGarageRepository()),
      Provider<FavoritesRepository>.value(value: _FakeFavoritesRepository()),
      Provider<PlatformRepository>.value(value: _FakePlatformRepository()),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AppScaffold(body: Center(child: Text(_homeBody))),
    ),
  );
}

Future<void> _openDrawer(WidgetTester tester) async {
  await tester.tap(find.byType(AppMenuButton));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('signed out: shows Entrar and no account row', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await _openDrawer(tester);

    expect(find.text('Entrar'), findsOneWidget);
    expect(find.byIcon(Icons.login), findsOneWidget);
    expect(find.text('Sair'), findsNothing);
    expect(find.byType(GoogleUserAvatar), findsNothing);
    expect(find.text('Busca'), findsOneWidget);
    expect(find.text('Defeitos'), findsOneWidget);
    expect(find.text('Sobre'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Garagem'), findsOneWidget);
    expect(find.text('Favoritos'), findsOneWidget);
  });

  testWidgets('shows Garagem right after Perfil and Favoritos right after '
      'Garagem', (WidgetTester tester) async {
    await tester.pumpWidget(_app());
    await _openDrawer(tester);

    final labels = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data)
        .toList();

    expect(labels.indexOf('Garagem'), labels.indexOf('Perfil') + 1);
    expect(labels.indexOf('Favoritos'), labels.indexOf('Garagem') + 1);
  });

  testWidgets('signed out: tapping Garagem opens the LoginView', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await _openDrawer(tester);

    await tester.tap(find.text('Garagem'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(GarageView), findsNothing);
  });

  testWidgets('signed out: tapping Perfil opens the LoginView', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await _openDrawer(tester);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(ProfileView), findsNothing);
  });

  testWidgets('signed in: tapping Garagem opens the GarageView', (
    WidgetTester tester,
  ) async {
    final session = AuthSessionViewModel()..setUser(_user);
    await tester.pumpWidget(_app(session: session));
    await _openDrawer(tester);

    await tester.tap(find.text('Garagem'));
    await tester.pumpAndSettle();

    expect(find.byType(GarageView), findsOneWidget);
  });

  testWidgets('signed out: tapping Favoritos opens the LoginView', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await _openDrawer(tester);

    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(FavoritesView), findsNothing);
  });

  testWidgets('signed in: tapping Favoritos opens the FavoritesView', (
    WidgetTester tester,
  ) async {
    final session = AuthSessionViewModel()..setUser(_user);
    await tester.pumpWidget(_app(session: session));
    await _openDrawer(tester);

    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();

    expect(find.byType(FavoritesView), findsOneWidget);
  });

  testWidgets('signed in: tapping Perfil opens the ProfileView', (
    WidgetTester tester,
  ) async {
    final session = AuthSessionViewModel()..setUser(_user);
    await tester.pumpWidget(_app(session: session));
    await _openDrawer(tester);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileView), findsOneWidget);
  });

  testWidgets('tapping Entrar opens the LoginView', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await _openDrawer(tester);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
  });

  testWidgets('tapping Sobre opens the AboutView', (WidgetTester tester) async {
    await tester.pumpWidget(_app());
    await _openDrawer(tester);

    await tester.tap(find.text('Sobre'));
    await tester.pumpAndSettle();

    expect(find.byType(AboutView), findsOneWidget);
  });

  testWidgets('tapping Defeitos opens the DefectsView', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await _openDrawer(tester);

    await tester.tap(find.text('Defeitos'));
    await tester.pumpAndSettle();

    expect(find.byType(DefectsView), findsOneWidget);
  });

  testWidgets('tapping Busca returns to the first route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await _openDrawer(tester);
    await tester.tap(find.text('Sobre'));
    await tester.pumpAndSettle();

    await _openDrawer(tester);
    await tester.tap(find.text('Busca'));
    await tester.pumpAndSettle();

    expect(find.byType(AboutView), findsNothing);
    expect(find.text(_homeBody), findsOneWidget);
  });

  testWidgets('signed in: shows the avatar, first name and Sair', (
    WidgetTester tester,
  ) async {
    final session = AuthSessionViewModel()..setUser(_user);
    await tester.pumpWidget(_app(session: session));
    await _openDrawer(tester);

    expect(find.byType(GoogleUserAvatar), findsOneWidget);
    expect(find.text('Daniel'), findsOneWidget);
    expect(find.text('Sair'), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);
    expect(find.text('Entrar'), findsNothing);
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Garagem'), findsOneWidget);
    expect(find.text('Favoritos'), findsOneWidget);
  });

  testWidgets('tapping Sair signs the user out', (WidgetTester tester) async {
    final session = AuthSessionViewModel()..setUser(_user);
    await tester.pumpWidget(_app(session: session));
    await _openDrawer(tester);

    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    expect(session.isSignedIn, isFalse);
  });

  testWidgets('the close button dismisses the drawer without throwing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await _openDrawer(tester);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
