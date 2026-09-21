import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/features/support/views/widgets/support_copy_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app() {
  return const MaterialApp(
    locale: Locale('pt'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SupportCopyField(
        label: 'Número MBWay',
        value: '+351 913 619 053',
        copyLabel: 'Copiar número',
      ),
    ),
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

  testWidgets('shows the label and value', (WidgetTester tester) async {
    await tester.pumpWidget(_app());

    expect(find.text('NÚMERO MBWAY'), findsOneWidget);
    expect(find.text('+351 913 619 053'), findsOneWidget);
    expect(find.text('Copiar número'), findsOneWidget);
  });

  testWidgets('copies the value and shows the "copied" feedback', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    await tester.tap(find.text('Copiar número'));
    await tester.pump();

    expect(copiedText, '+351 913 619 053');
    expect(find.text('Copiado!'), findsOneWidget);
  });

  testWidgets('reverts to the copy label after the feedback duration', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    await tester.tap(find.text('Copiar número'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Copiar número'), findsOneWidget);
    expect(find.text('Copiado!'), findsNothing);
  });
}
