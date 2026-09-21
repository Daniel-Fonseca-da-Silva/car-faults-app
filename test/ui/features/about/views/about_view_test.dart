import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/constants/app_brand.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/features/about/views/about_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class _FakeUrlLauncher extends UrlLauncherPlatform {
  String? lastLaunchedUrl;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    lastLaunchedUrl = url;
    return true;
  }
}

Widget _app({Widget home = const AboutView()}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => LocaleViewModel(
          repository: LocaleRepository(service: LocalePreferencesService()),
        ),
      ),
      ChangeNotifierProvider(create: (_) => AuthSessionViewModel()),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

void main() {
  late _FakeUrlLauncher fakeUrlLauncher;

  setUp(() {
    fakeUrlLauncher = _FakeUrlLauncher();
    UrlLauncherPlatform.instance = fakeUrlLauncher;
  });

  testWidgets('shows the title and the founder photo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(find.text('Sobre a Auto Crónica'), findsOneWidget);
    final photo = find.bySemanticsLabel(
      'O meu Volkswagen 1300 de 1973, o carocha que tenho na garagem',
    );
    expect(photo, findsOneWidget);
    expect(
      find.descendant(of: photo, matching: find.byType(Image)),
      findsOneWidget,
    );
  });

  testWidgets('shows the lead and the three copy sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(
      find.textContaining('A Auto Crónica nasceu do encontro'),
      findsOneWidget,
    );
    expect(find.text('O problema'), findsOneWidget);
    expect(find.text('A solução'), findsOneWidget);
    expect(find.text('Para quem gosta mesmo de carros'), findsOneWidget);
  });

  testWidgets('opens the founder LinkedIn profile', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    await tester.tap(find.text('Ver perfil no LinkedIn'));
    await tester.pumpAndSettle();

    expect(fakeUrlLauncher.lastLaunchedUrl, AppBrand.founderLinkedinUrl);
  });

  testWidgets('the CTA pops back to the home screen', (
    WidgetTester tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      _app(
        home: Builder(
          builder: (context) => Navigator(
            key: navigatorKey,
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (_) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => navigatorKey.currentState!.push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AboutView(),
                      ),
                    ),
                    child: const Text('open about'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open about'));
    await tester.pumpAndSettle();
    expect(find.byType(AboutView), findsOneWidget);

    await tester.ensureVisible(find.text('Pesquisar defeitos'));
    await tester.tap(find.text('Pesquisar defeitos'));
    await tester.pumpAndSettle();

    expect(find.byType(AboutView), findsNothing);
    expect(find.text('open about'), findsOneWidget);
  });
}
