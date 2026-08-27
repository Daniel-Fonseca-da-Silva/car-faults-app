import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/features/lookup/views/lookup_results_view.dart';
import 'package:car_faults_app/ui/features/lookup/views/widgets/lookup_issue_card.dart';
import 'package:flutter/material.dart';
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
      home: LookupResultsView(),
    ),
  );
}

Finder _card(String title) {
  return find.ancestor(
    of: find.text(title),
    matching: find.byType(LookupIssueCard),
  );
}

Finder _inCard(String title, Finder matching) {
  return find.descendant(of: _card(title), matching: matching);
}

Future<void> _openIssue(WidgetTester tester, String title) async {
  final titleFinder = find.text(title);
  await tester.ensureVisible(titleFinder);
  await tester.pumpAndSettle();
  await tester.tap(titleFinder);
  await tester.pumpAndSettle();
}

void main() {
  const gearboxTitle = 'Caixa de câmbio problemática';

  testWidgets('shows the 3 issue titles collapsed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(find.text(gearboxTitle), findsOneWidget);
    expect(find.text('Corrosão na estrutura do assoalho'), findsOneWidget);
    expect(find.text('Falha no sistema de arrefecimento'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(LookupIssueCard),
        matching: find.byIcon(Icons.expand_more),
      ),
      findsNWidgets(3),
    );
    expect(
      find.descendant(
        of: find.byType(LookupIssueCard),
        matching: find.byIcon(Icons.expand_less),
      ),
      findsNothing,
    );
  });

  testWidgets('tapping the first card reveals its description and sources', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    await _openIssue(tester, gearboxTitle);

    expect(
      find.descendant(
        of: find.byType(LookupIssueCard),
        matching: find.byIcon(Icons.expand_less),
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('sincronizadores da 2ª e 3ª velocidade'),
      findsOneWidget,
    );
    expect(_inCard(gearboxTitle, find.text('FONTES')), findsOneWidget);
    expect(
      find.text('https://www.auto.pt/forum/polo-cambio-sincronizadores'),
      findsOneWidget,
    );
  });
}
