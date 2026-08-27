import 'package:car_faults_app/ui/core/widgets/app_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  testWidgets('shows the label and calls onPressed when tapped', (
    WidgetTester tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      _app(
        AppPrimaryButton(label: 'Pesquisar', onPressed: () => tapped = true),
      ),
    );

    expect(find.text('Pesquisar'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsNothing);

    await tester.tap(find.byType(AppPrimaryButton));
    expect(tapped, isTrue);
  });

  testWidgets('shows the icon next to the label when provided', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        AppPrimaryButton(
          label: 'Pesquisar',
          icon: Icons.search,
          onPressed: () {},
        ),
      ),
    );

    expect(find.text('Pesquisar'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('disables onPressed and shows a spinner when isLoading', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        AppPrimaryButton(label: 'Pesquisar', onPressed: () {}, isLoading: true),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Pesquisar'), findsNothing);

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });
}
