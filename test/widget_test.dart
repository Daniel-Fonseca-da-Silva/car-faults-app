import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:car_faults_app/main.dart';
import 'package:car_faults_app/ui/core/widgets/brand_wordmark.dart';
import 'package:car_faults_app/ui/core/widgets/google_sign_in_button.dart';
import 'package:car_faults_app/ui/core/widgets/section_eyebrow.dart';
import 'package:car_faults_app/ui/features/login/views/widgets/login_access_section.dart';
import 'package:car_faults_app/ui/features/login/views/widgets/login_header.dart';
import 'package:car_faults_app/ui/features/login/views/widgets/login_hero_section.dart';
import 'package:car_faults_app/ui/features/login/views/widgets/login_sign_up_prompt.dart';

void main() {
  testWidgets('LoginView shows the header with logo, wordmark and avatar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CarFaultsApp());

    expect(
      find.descendant(
        of: find.byType(LoginHeader),
        matching: find.byType(Image),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.person), findsOneWidget);

    final wordmark = tester.widget<Text>(
      find.descendant(
        of: find.byType(BrandWordmark),
        matching: find.byType(Text),
      ),
    );
    expect(wordmark.textSpan!.toPlainText(), 'AUTOCRÓNICA');
  });

  testWidgets('LoginView shows the hero photo, eyebrow and title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CarFaultsApp());

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
      await tester.pumpWidget(const CarFaultsApp());

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
      await tester.pumpWidget(const CarFaultsApp());

      await tester.tap(find.text('Continuar com Google'));
      await tester.pumpAndSettle();

      expect(
        find.text('Login com Google em breve disponível.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('tapping "Cadastre-se grátis" triggers the same Google command', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CarFaultsApp());

    await tester.tap(find.text('Cadastre-se grátis'));
    await tester.pumpAndSettle();

    expect(find.text('Login com Google em breve disponível.'), findsOneWidget);
  });
}
