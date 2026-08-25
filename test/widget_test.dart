import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:car_faults_app/data/repositories/auth_repository.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/core/widgets/app_footer.dart';
import 'package:car_faults_app/ui/core/widgets/app_header.dart';
import 'package:car_faults_app/ui/core/widgets/brand_wordmark.dart';
import 'package:car_faults_app/ui/core/widgets/google_sign_in_button.dart';
import 'package:car_faults_app/ui/core/widgets/section_eyebrow.dart';
import 'package:car_faults_app/ui/features/legal/views/legal_view.dart';
import 'package:car_faults_app/ui/features/login/view_models/login_view_model.dart';
import 'package:car_faults_app/ui/features/login/views/login_view.dart';
import 'package:car_faults_app/ui/features/login/views/widgets/login_access_section.dart';
import 'package:car_faults_app/ui/features/login/views/widgets/login_hero_section.dart';
import 'package:car_faults_app/ui/features/login/views/widgets/login_sign_up_prompt.dart';
import 'package:car_faults_app/ui/features/login/views/widgets/login_stat_item.dart';
import 'package:car_faults_app/ui/features/login/views/widgets/login_stats_section.dart';

Widget _loginApp() {
  return ChangeNotifierProvider(
    create: (_) => LoginViewModel(authRepository: AuthRepository()),
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
  testWidgets('LoginView shows the header with logo, wordmark and avatar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_loginApp());

    expect(
      find.descendant(of: find.byType(AppHeader), matching: find.byType(Image)),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.person), findsOneWidget);

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
  });

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

  testWidgets(
    'tapping the Google button shows a SnackBar with the stub result',
    (WidgetTester tester) async {
      await tester.pumpWidget(_loginApp());

      await tester.tap(find.text('Continuar com Google'));
      await tester.pumpAndSettle();

      expect(
        find.text('Login com Google em breve disponível.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('LoginView shows the three stats with their labels', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_loginApp());

    expect(find.byType(LoginStatsSection), findsOneWidget);
    expect(find.byType(LoginStatItem), findsNWidgets(3));

    expect(find.text('1.2M+'), findsOneWidget);
    expect(find.text('defeitos'), findsOneWidget);
    expect(find.text('8.4K+'), findsOneWidget);
    expect(find.text('modelos'), findsOneWidget);
    expect(find.text('34K+'), findsOneWidget);
    expect(find.text('recalls'), findsOneWidget);
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
    await tester.pumpWidget(_loginApp());

    await tester.tap(find.text('Cadastre-se grátis'));
    await tester.pumpAndSettle();

    expect(find.text('Login com Google em breve disponível.'), findsOneWidget);
  });
}
