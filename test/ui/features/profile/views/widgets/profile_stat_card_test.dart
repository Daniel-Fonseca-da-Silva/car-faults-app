import 'package:car_faults_app/ui/features/profile/views/widgets/profile_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app() {
  return const MaterialApp(
    home: Scaffold(
      body: ProfileStatCard(
        icon: Icons.search,
        value: '47',
        label: 'Buscas realizadas',
      ),
    ),
  );
}

void main() {
  testWidgets('shows the value and the label', (WidgetTester tester) async {
    await tester.pumpWidget(_app());

    expect(find.text('47'), findsOneWidget);
    expect(find.text('Buscas realizadas'), findsOneWidget);
  });

  testWidgets('exposes value and label as a single semantics label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(find.bySemanticsLabel('47 Buscas realizadas'), findsOneWidget);
  });
}
