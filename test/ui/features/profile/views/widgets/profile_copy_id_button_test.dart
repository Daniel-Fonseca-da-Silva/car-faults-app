import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/features/profile/views/widgets/profile_copy_id_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _accountId = 'b3a5c1d2-4e6f-4a8b-9c0d-1e2f3a4b5c6d';

Widget _app() {
  return const MaterialApp(
    locale: Locale('pt'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: ProfileCopyIdButton(accountId: _accountId)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  String? copiedText;

  setUp(() {
    copiedText = null;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copiedText = (call.arguments as Map)['text'] as String;
      }
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('starts with the "copy" semantic label', (
    WidgetTester tester,
  ) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(_app());

    expect(find.bySemanticsLabel('Copiar ID da conta'), findsOneWidget);

    handle.dispose();
  });

  testWidgets('copies the account id and switches to the "copied" label', (
    WidgetTester tester,
  ) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(_app());
    await tester.tap(find.byType(ProfileCopyIdButton));
    await tester.pump();

    expect(copiedText, _accountId);
    expect(find.bySemanticsLabel('ID copiado'), findsOneWidget);

    handle.dispose();
  });

  testWidgets('reverts to the "copy" label after the feedback duration', (
    WidgetTester tester,
  ) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(_app());
    await tester.tap(find.byType(ProfileCopyIdButton));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.bySemanticsLabel('Copiar ID da conta'), findsOneWidget);

    handle.dispose();
  });
}
