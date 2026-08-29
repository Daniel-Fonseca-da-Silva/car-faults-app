import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:car_faults_app/domain/models/known_issue.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/features/garage/views/widgets/garage_known_issues_section.dart';
import 'package:car_faults_app/ui/features/lookup/views/lookup_results_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const _issues = <KnownIssue>[
  KnownIssue(
    id: 'timing-belt-wear',
    title: 'Timing belt wear and failure',
    description: 'The timing belt can deteriorate and break.',
    severity: IssueSeverity.high,
    sources: ['Fiat workshop manual'],
    fixes: [],
    reviews: [],
  ),
  KnownIssue(
    id: 'ignition-coil-failure',
    title: 'Ignition coil failure',
    description: 'Ignition coils can develop internal cracks.',
    severity: IssueSeverity.medium,
    sources: ['AutoDoc'],
    fixes: [],
    reviews: [],
  ),
  KnownIssue(
    id: 'fuel-pump-failure',
    title: 'Fuel pump failure',
    description: 'The electric fuel pump may fail.',
    severity: IssueSeverity.medium,
    sources: ['Fiat service bulletin'],
    fixes: [],
    reviews: [],
  ),
];

Widget _app({List<KnownIssue> issues = const []}) {
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
      home: Scaffold(body: GarageKnownIssuesSection(issues: issues)),
    ),
  );
}

void main() {
  testWidgets('shows the three demo issues, their badges and sources', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(issues: _issues));

    expect(find.text('Timing belt wear and failure'), findsOneWidget);
    expect(find.text('Ignition coil failure'), findsOneWidget);
    expect(find.text('Fuel pump failure'), findsOneWidget);
    expect(find.text('Alta'), findsOneWidget);
    expect(find.text('Média'), findsNWidgets(2));
    expect(find.text('Fontes: Fiat workshop manual'), findsOneWidget);
    expect(find.text('Fontes: AutoDoc'), findsOneWidget);
    expect(find.text('Fontes: Fiat service bulletin'), findsOneWidget);
  });

  testWidgets('empty issues renders nothing', (WidgetTester tester) async {
    await tester.pumpWidget(_app());

    expect(find.text('DEFEITOS CONHECIDOS'), findsNothing);
    expect(find.text('Ver detalhes'), findsNothing);
  });

  testWidgets('tapping "Ver detalhes" pushes LookupResultsView', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(issues: _issues));

    await tester.tap(find.text('Ver detalhes'));
    await tester.pumpAndSettle();

    expect(find.byType(LookupResultsView), findsOneWidget);
  });
}
