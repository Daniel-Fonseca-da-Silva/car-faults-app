import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:car_faults_app/main.dart';
import 'package:car_faults_app/ui/core/widgets/brand_wordmark.dart';
import 'package:car_faults_app/ui/features/login/views/widgets/login_header.dart';

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
}
