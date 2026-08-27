import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/widgets/app_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tapping the button opens the Scaffold end drawer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          endDrawer: const Drawer(child: Text('drawer content')),
          appBar: AppBar(actions: const [AppMenuButton()]),
        ),
      ),
    );

    await tester.tap(find.byType(AppMenuButton));
    await tester.pumpAndSettle();

    expect(find.text('drawer content'), findsOneWidget);
  });
}
