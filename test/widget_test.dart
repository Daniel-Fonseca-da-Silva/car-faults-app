import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:car_faults_app/main.dart';
import 'package:car_faults_app/ui/core/widgets/brand_wordmark.dart';
import 'package:car_faults_app/ui/core/widgets/section_eyebrow.dart';
import 'package:car_faults_app/ui/features/login/views/widgets/login_header.dart';
import 'package:car_faults_app/ui/features/login/views/widgets/login_hero_section.dart';

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
    expect(find.byType(SectionEyebrow), findsOneWidget);
    expect(find.text('CARFAULTS'), findsOneWidget);
  });
}
