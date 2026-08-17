import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:car_faults_app/main.dart';

void main() {
  testWidgets('LoginView shows the header with logo, wordmark and avatar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CarFaultsApp());

    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);

    final wordmark = tester.widget<Text>(find.byType(Text));
    expect(wordmark.textSpan!.toPlainText(), 'CARFAULTS');
  });
}
