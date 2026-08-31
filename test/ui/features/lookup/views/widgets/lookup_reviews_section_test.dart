import 'package:car_faults_app/data/repositories/auth_repository.dart';
import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/domain/models/user.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/features/login/views/login_view.dart';
import 'package:car_faults_app/ui/features/lookup/views/lookup_results_view.dart';
import 'package:car_faults_app/ui/features/lookup/views/widgets/lookup_issue_card.dart';
import 'package:car_faults_app/ui/features/lookup/views/widgets/lookup_star_rating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const _signedInUser = User(
  id: 'u1',
  name: 'Daniel Fonseca',
  email: 'daniel@example.com',
);

Widget _app({AuthSessionViewModel? session}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => LocaleViewModel(
          repository: LocaleRepository(service: LocalePreferencesService()),
        ),
      ),
      ChangeNotifierProvider.value(value: session ?? AuthSessionViewModel()),
      Provider<AuthRepository>.value(value: AuthRepository()),
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
  const corrosionTitle = 'Corrosão na estrutura do assoalho';
  const emptyState =
      'Sem avaliações ainda. Sê o primeiro a classificar este defeito.';

  testWidgets(
    'the gearbox issue shows the 4.3 average and the 3 reviewer names',
    (WidgetTester tester) async {
      await tester.pumpWidget(_app());

      await _openIssue(tester, gearboxTitle);

      expect(_inCard(gearboxTitle, find.text('4.3')), findsOneWidget);
      expect(_inCard(gearboxTitle, find.text('3 avaliações')), findsOneWidget);
      expect(_inCard(gearboxTitle, find.text('Ricardo Moura')), findsOneWidget);
      expect(_inCard(gearboxTitle, find.text('Fábio Lopes')), findsOneWidget);
      expect(_inCard(gearboxTitle, find.text('Ana Silva')), findsOneWidget);
      expect(
        _inCard(gearboxTitle, find.text('a tua avaliação')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'the corrosion issue shows the empty state and a form; submitting it '
    'while signed in reveals the "a tua avaliação" badge',
    (WidgetTester tester) async {
      final session = AuthSessionViewModel()..setUser(_signedInUser);
      await tester.pumpWidget(_app(session: session));

      await _openIssue(tester, corrosionTitle);

      expect(_inCard(corrosionTitle, find.text(emptyState)), findsOneWidget);
      expect(
        _inCard(corrosionTitle, find.text('a tua avaliação')),
        findsNothing,
      );
      expect(
        _inCard(corrosionTitle, find.text('Submeter avaliação')),
        findsOneWidget,
      );

      final submitButtonFinder = _inCard(
        corrosionTitle,
        find.byType(ElevatedButton),
      );
      final submitButton = tester.widget<ElevatedButton>(submitButtonFinder);
      expect(submitButton.onPressed, isNull);

      final fourthStar = _inCard(corrosionTitle, find.byType(IconButton)).at(3);
      await tester.ensureVisible(fourthStar);
      await tester.tap(fourthStar);
      await tester.pump();

      await tester.ensureVisible(submitButtonFinder);
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      expect(
        _inCard(corrosionTitle, find.text('a tua avaliação')),
        findsOneWidget,
      );
      expect(
        _inCard(corrosionTitle, find.byType(LookupStarRating)),
        findsWidgets,
      );
      expect(
        _inCard(corrosionTitle, find.text('Submeter avaliação')),
        findsNothing,
      );
    },
  );

  testWidgets('submitting a review while signed out asks to sign in first', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    await _openIssue(tester, corrosionTitle);

    final fourthStar = _inCard(corrosionTitle, find.byType(IconButton)).at(3);
    await tester.ensureVisible(fourthStar);
    await tester.tap(fourthStar);
    await tester.pump();

    final submitButtonFinder = _inCard(
      corrosionTitle,
      find.byType(ElevatedButton),
    );
    await tester.ensureVisible(submitButtonFinder);
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
  });
}
