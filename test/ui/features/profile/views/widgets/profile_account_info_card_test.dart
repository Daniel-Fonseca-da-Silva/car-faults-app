import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/features/profile/profile_demo_display.dart';
import 'package:car_faults_app/ui/features/profile/views/widgets/profile_account_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app() {
  return MaterialApp(
    locale: const Locale('pt'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: ProfileAccountInfoCard(snapshot: ProfileDemoDisplay.snapshot),
    ),
  );
}

void main() {
  testWidgets('shows the title, email, formatted dates and account id prefix', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(find.text('INFORMAÇÕES DA CONTA'), findsOneWidget);
    expect(find.text('ana@example.com'), findsOneWidget);
    expect(find.text('17 de julho de 2026'), findsNWidgets(2));
    expect(find.textContaining('b3a5c1d2'), findsOneWidget);
  });
}
