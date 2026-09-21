import 'package:car_faults_app/ui/features/support/views/widgets/support_amount_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app() {
  return const MaterialApp(
    home: Scaffold(
      body: SupportAmountTile(
        emoji: '☕',
        amountLabel: '€ 2',
        label: 'Um café',
      ),
    ),
  );
}

void main() {
  testWidgets('shows the emoji, amount and label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(find.text('☕'), findsOneWidget);
    expect(find.text('€ 2'), findsOneWidget);
    expect(find.text('Um café'), findsOneWidget);
  });
}
