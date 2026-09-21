import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/constants/app_support.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/features/support/views/support_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _app() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => LocaleViewModel(
          repository: LocaleRepository(service: LocalePreferencesService()),
        ),
      ),
      ChangeNotifierProvider(create: (_) => AuthSessionViewModel()),
    ],
    child: const MaterialApp(
      locale: Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SupportView(),
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

  testWidgets('shows the hero photo, title and author', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    final photo = find.bySemanticsLabel('O meu Volkswagen Polo 6N1');
    expect(photo, findsOneWidget);
    expect(
      find.descendant(of: photo, matching: find.byType(Image)),
      findsOneWidget,
    );
    expect(find.text('Apoia o Auto Crónica'), findsOneWidget);
    // Appears twice: the author byline in the hero and the closing signature.
    expect(find.text('Daniel Fonseca da Silva'), findsNWidgets(2));
    expect(
      find.text('Criador e único programador do Auto Crónica'),
      findsOneWidget,
    );
  });

  testWidgets('shows the three benefit cards', (WidgetTester tester) async {
    await tester.pumpWidget(_app());

    expect(find.text('Para que serve a tua doação'), findsOneWidget);
    expect(find.text('Mantém os servidores a funcionar'), findsOneWidget);
    expect(find.text('Incentivo para novas funcionalidades'), findsOneWidget);
    expect(find.text('Um café para o programador'), findsOneWidget);
  });

  testWidgets('shows the MBWay, Wise and Pix donation sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(find.text('☕ Oferece-me um café'), findsOneWidget);
    expect(find.text('+351 913 619 053'), findsOneWidget);

    expect(find.text('🌍 Fora de Portugal? Paga com a Wise'), findsOneWidget);
    expect(find.text('https://wise.com/pay/me/danielf6030'), findsOneWidget);

    expect(find.text('🇧🇷 No Brasil? Paga por Pix'), findsOneWidget);
    expect(find.text('309ecf2b-ec2b-4f9a-916b-061e298ab6fc'), findsOneWidget);
  });

  testWidgets('shows the suggested amount tiles', (WidgetTester tester) async {
    await tester.pumpWidget(_app());

    expect(find.text('SUGESTÕES DE VALORES'), findsOneWidget);
    expect(find.text('€ 2'), findsOneWidget);
    expect(find.text('€ 5'), findsOneWidget);
    expect(find.text('€ 10'), findsOneWidget);
  });

  testWidgets('shows the thanks section', (WidgetTester tester) async {
    await tester.pumpWidget(_app());

    expect(find.text('Obrigado! 🙌'), findsOneWidget);
  });

  testWidgets(
    'copies the Pix code and shows the "copied" feedback that reverts',
    (WidgetTester tester) async {
      await tester.pumpWidget(_app());

      await tester.ensureVisible(find.text('Copiar código Pix'));
      await tester.tap(find.text('Copiar código Pix'));
      await tester.pump();

      expect(copiedText, AppSupport.pixBrCode);
      expect(find.text('Copiado!'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Copiar código Pix'), findsOneWidget);
    },
  );
}
