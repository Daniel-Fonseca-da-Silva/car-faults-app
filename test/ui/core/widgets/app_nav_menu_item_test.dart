import 'package:car_faults_app/ui/core/widgets/app_nav_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the label and icon, and calls onTap', (
    WidgetTester tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppNavMenuItem(
            icon: Icons.login,
            label: 'Entrar',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Entrar'), findsOneWidget);
    expect(find.byIcon(Icons.login), findsOneWidget);

    await tester.tap(find.text('Entrar'));
    expect(tapped, isTrue);
  });

  testWidgets('omits the icon when none is given', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppNavMenuItem(label: 'Defeitos', onTap: () {}),
        ),
      ),
    );

    expect(find.text('Defeitos'), findsOneWidget);
    expect(find.byType(Icon), findsNothing);
  });
}
