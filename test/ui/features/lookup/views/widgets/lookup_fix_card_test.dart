import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/features/lookup/views/lookup_results_view.dart';
import 'package:car_faults_app/ui/features/lookup/views/widgets/lookup_fix_card.dart';
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

  testWidgets(
    'the gearbox issue shows its 2 fixes with the € 450 and € 55 badges',
    (WidgetTester tester) async {
      await tester.pumpWidget(_app());

      await _openIssue(tester, gearboxTitle);

      expect(
        _inCard(gearboxTitle, find.byType(LookupFixCard)),
        findsNWidgets(2),
      );
      expect(_inCard(gearboxTitle, find.text('€ 450')), findsOneWidget);
      expect(_inCard(gearboxTitle, find.text('€ 55')), findsOneWidget);
    },
  );

  testWidgets(
    'tapping "Ver passo a passo" on the overhaul fix reveals its 6 steps',
    (WidgetTester tester) async {
      await tester.pumpWidget(_app());

      await _openIssue(tester, gearboxTitle);

      const viewSteps = 'Ver passo a passo (6 etapas)';
      final viewStepsFinder = _inCard(gearboxTitle, find.text(viewSteps));
      expect(viewStepsFinder, findsOneWidget);
      expect(
        _inCard(
          gearboxTitle,
          find.text('Remover a caixa de câmbio do veículo.'),
        ),
        findsNothing,
      );

      await tester.ensureVisible(viewStepsFinder);
      await tester.tap(viewStepsFinder);
      await tester.pumpAndSettle();

      expect(
        _inCard(
          gearboxTitle,
          find.text('Remover a caixa de câmbio do veículo.'),
        ),
        findsOneWidget,
      );
      expect(
        _inCard(
          gearboxTitle,
          find.text('Instalar a caixa e testar todas as marchas em estrada.'),
        ),
        findsOneWidget,
      );
      expect(
        _inCard(gearboxTitle, find.text('Ocultar passo a passo')),
        findsOneWidget,
      );
    },
  );

  testWidgets('tapping the thumbs up button increments its count', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    await _openIssue(tester, gearboxTitle);

    expect(_inCard(gearboxTitle, find.text('312')), findsOneWidget);

    final thumbsUp = _inCard(
      gearboxTitle,
      find.byIcon(Icons.thumb_up_outlined),
    ).first;
    await tester.ensureVisible(thumbsUp);
    await tester.tap(thumbsUp);
    await tester.pump();

    expect(_inCard(gearboxTitle, find.text('313')), findsOneWidget);
  });
}
