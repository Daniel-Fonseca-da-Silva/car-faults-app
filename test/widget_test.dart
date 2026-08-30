import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:car_faults_app/data/repositories/auth_repository.dart';
import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/core/widgets/app_footer.dart';
import 'package:car_faults_app/ui/core/widgets/app_header.dart';
import 'package:car_faults_app/ui/core/widgets/app_menu_button.dart';
import 'package:car_faults_app/ui/core/widgets/brand_wordmark.dart';
import 'package:car_faults_app/ui/core/widgets/google_sign_in_button.dart';
import 'package:car_faults_app/ui/core/widgets/locale_switcher.dart';
import 'package:car_faults_app/ui/core/widgets/section_eyebrow.dart';
import 'package:car_faults_app/ui/features/legal/views/legal_view.dart';
import 'package:car_faults_app/ui/features/login/view_models/login_view_model.dart';
import 'package:car_faults_app/ui/features/login/views/login_view.dart';
import 'package:car_faults_app/ui/features/login/views/widgets/login_access_section.dart';
import 'package:car_faults_app/ui/features/login/views/widgets/login_hero_section.dart';
import 'package:car_faults_app/ui/features/login/views/widgets/login_sign_up_prompt.dart';

/// Resolves to a network failure without touching the real Google Sign-In
/// SDK or network, so the SnackBar error path can be tested deterministically.
class _FailingAuthRepository extends AuthRepository {
  @override
  Future<AuthResult?> signInWithGoogle() async =>
      const AuthFailure(AuthFailureReason.network);
}

Widget _loginApp({AuthRepository? authRepository}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) =>
            LoginViewModel(authRepository: authRepository ?? AuthRepository()),
      ),
      ChangeNotifierProvider(
        create: (_) => LocaleViewModel(
          repository: LocaleRepository(service: LocalePreferencesService()),
        ),
      ),
      ChangeNotifierProvider(create: (_) => AuthSessionViewModel()),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const LoginView(),
    ),
  );
}

void main() {
  testWidgets(
    'LoginView shows the header with logo, wordmark, locale switcher and menu',
    (WidgetTester tester) async {
      await tester.pumpWidget(_loginApp());

      expect(
        find.descendant(
          of: find.byType(AppHeader),
          matching: find.byType(Image),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AppHeader),
          matching: find.byType(LocaleSwitcher),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AppHeader),
          matching: find.byType(AppMenuButton),
        ),
        findsOneWidget,
      );

      final wordmark = tester.widget<Text>(
        find.descendant(
          of: find.descendant(
            of: find.byType(AppHeader),
            matching: find.byType(BrandWordmark),
          ),
          matching: find.byType(Text),
        ),
      );
      expect(wordmark.textSpan!.toPlainText(), 'AUTOCRÓNICA');
    },
  );

  testWidgets('LoginView shows the hero photo, eyebrow and title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_loginApp());

    expect(find.byType(LoginHeroSection), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(LoginHeroSection),
        matching: find.byType(Image),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(LoginHeroSection),
        matching: find.byType(SectionEyebrow),
      ),
      findsOneWidget,
    );
    expect(find.text('CARFAULTS'), findsOneWidget);
  });

  testWidgets(
    'LoginView shows the Google access block and the sign-up prompt',
    (WidgetTester tester) async {
      await tester.pumpWidget(_loginApp());

      expect(find.byType(LoginAccessSection), findsOneWidget);
      expect(find.text('Entrar na conta'), findsOneWidget);
      expect(
        find.text('Bem-vindo de volta. Acesse o banco de defeitos.'),
        findsOneWidget,
      );
      expect(find.byType(GoogleSignInButton), findsOneWidget);
      expect(find.text('Continuar com Google'), findsOneWidget);

      expect(find.byType(LoginSignUpPrompt), findsOneWidget);
      expect(find.text('Não tem conta?'), findsOneWidget);
      expect(find.text('Cadastre-se grátis'), findsOneWidget);
    },
  );

  testWidgets('tapping the Google button shows a SnackBar on failure', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _loginApp(authRepository: _FailingAuthRepository()),
    );

    await tester.tap(find.text('Continuar com Google'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Não foi possível ligar ao servidor. '
        'Verifica a tua ligação e tenta novamente.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('LoginView shows the footer wordmark, disclaimer and copyright', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_loginApp());
    await tester.scrollUntilVisible(find.byType(AppFooter), 200);

    expect(
      find.descendant(
        of: find.byType(AppFooter),
        matching: find.byType(BrandWordmark),
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Dados obtidos de relatos públicos, fóruns ou pelo uso de agentes e IA.',
      ),
      findsOneWidget,
    );
    expect(find.text('© 2026'), findsOneWidget);
  });

  testWidgets('LoginView footer shows Privacy and Terms links', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_loginApp());
    await tester.scrollUntilVisible(find.text('Privacidade'), 200);

    expect(
      find.descendant(
        of: find.byType(AppFooter),
        matching: find.text('Privacidade'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(AppFooter),
        matching: find.text('Termos'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('tapping Privacidade opens the LegalView', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_loginApp());
    await tester.scrollUntilVisible(find.text('Privacidade'), 200);

    await tester.tap(find.text('Privacidade'));
    await tester.pumpAndSettle();

    expect(find.byType(LegalView), findsOneWidget);
    expect(find.text('Privacidade e Termos de Uso'), findsOneWidget);
  });

  testWidgets('tapping "Cadastre-se grátis" triggers the same Google command', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _loginApp(authRepository: _FailingAuthRepository()),
    );

    await tester.tap(find.text('Cadastre-se grátis'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Não foi possível ligar ao servidor. '
        'Verifica a tua ligação e tenta novamente.',
      ),
      findsOneWidget,
    );
  });
}
