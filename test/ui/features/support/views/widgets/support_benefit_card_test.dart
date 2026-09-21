import 'package:car_faults_app/ui/features/support/views/widgets/support_benefit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app() {
  return const MaterialApp(
    home: Scaffold(
      body: SupportBenefitCard(
        emoji: '🖥️',
        title: 'Mantém os servidores a funcionar',
        body: 'A tua doação ajuda a pagar o alojamento.',
      ),
    ),
  );
}

void main() {
  testWidgets('shows the emoji, title and body', (WidgetTester tester) async {
    await tester.pumpWidget(_app());

    expect(find.text('🖥️'), findsOneWidget);
    expect(find.text('Mantém os servidores a funcionar'), findsOneWidget);
    expect(
      find.text('A tua doação ajuda a pagar o alojamento.'),
      findsOneWidget,
    );
  });
}
