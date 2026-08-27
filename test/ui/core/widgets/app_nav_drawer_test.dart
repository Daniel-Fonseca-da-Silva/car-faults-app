import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/domain/models/user.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/core/widgets/app_menu_button.dart';
import 'package:car_faults_app/ui/core/widgets/app_scaffold.dart';
import 'package:car_faults_app/ui/core/widgets/google_user_avatar.dart';
import 'package:car_faults_app/ui/features/about/views/about_view.dart';
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

Widget _app({AuthSessionViewModel? session}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => LocaleViewModel(
          repository: LocaleRepository(service: LocalePreferencesService()),
        ),
      ),
      ChangeNotifierProvider.value(value: session ?? AuthSessionViewModel()),
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
    expect(find.text('Defeitos'), findsOneWidget);
    expect(find.text('Sobre'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
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

  testWidgets('tapping Perfil opens the ProfileView', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await _openDrawer(tester);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileView), findsOneWidget);
  });

  testWidgets('tapping Defeitos returns to the first route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await _openDrawer(tester);
    await tester.tap(find.text('Sobre'));
    await tester.pumpAndSettle();

    await _openDrawer(tester);
    await tester.tap(find.text('Defeitos'));
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
