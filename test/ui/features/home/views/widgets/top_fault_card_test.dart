import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:car_faults_app/domain/models/top_fault.dart';
import 'package:car_faults_app/ui/features/home/views/widgets/top_fault_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const fault = TopFault(
    id: 'injection',
    title: 'Falha no sistema de injeção eletrónica',
    severity: IssueSeverity.high,
    reportCount: 1842,
    vehicleBrand: 'Volkswagen',
    vehicleModel: 'Gol',
    vehicleYearFrom: 2015,
  );

  Future<void> pumpCard(WidgetTester tester) {
    return tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TopFaultCard(fault: fault, viewReportsLabel: 'Ver relatos'),
        ),
      ),
    );
  }

  testWidgets('shows brand, model, year, formatted count and description', (
    WidgetTester tester,
  ) async {
    await pumpCard(tester);

    expect(find.text('Volkswagen Gol'), findsOneWidget);
    expect(find.text('2015'), findsOneWidget);
    expect(find.text('1.842'), findsOneWidget);
    expect(find.text('Falha no sistema de injeção eletrónica'), findsOneWidget);
    expect(find.text('Ver relatos'), findsOneWidget);
  });

  testWidgets('exposes a single composed semantic label for the card', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semanticsHandle = tester.ensureSemantics();

    await pumpCard(tester);

    expect(
      find.bySemanticsLabel(
        'Volkswagen Gol, 2015, Falha no sistema de injeção eletrónica, 1.842',
      ),
      findsOneWidget,
    );

    semanticsHandle.dispose();
  });
}
