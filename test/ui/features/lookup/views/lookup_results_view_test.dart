import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/core/widgets/app_footer.dart';
import 'package:car_faults_app/ui/features/lookup/views/lookup_results_view.dart';
import 'package:car_faults_app/ui/features/lookup/views/widgets/lookup_back_link.dart';
import 'package:car_faults_app/ui/features/lookup/views/widgets/lookup_issue_card.dart';
import 'package:car_faults_app/ui/features/lookup/views/widgets/lookup_issues_summary.dart';
import 'package:car_faults_app/ui/features/lookup/views/widgets/lookup_tech_specs.dart';
import 'package:car_faults_app/ui/features/lookup/views/widgets/lookup_vehicle_hero.dart';
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
    child: MaterialApp(
      theme: AppTheme.dark,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const LookupResultsView(),
                ),
              ),
              child: const Text('open results'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the back link and the shared footer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('open results'));
    await tester.pumpAndSettle();

    expect(find.byType(LookupBackLink), findsOneWidget);
    expect(find.text('Nova busca'), findsOneWidget);
    expect(find.byType(LookupVehicleHero), findsOneWidget);
    expect(find.byType(LookupTechSpecs), findsOneWidget);
    expect(find.byType(LookupIssuesSummary), findsOneWidget);
    expect(find.byType(LookupIssueCard), findsNWidgets(3));
    expect(find.byType(AppFooter), findsOneWidget);
    expect(
      find.text(
        'Dados obtidos de relatos públicos e entidades reguladoras. '
        'Não substitui uma avaliação técnica.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('tapping the back link pops the route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('open results'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(LookupBackLink));
    await tester.pumpAndSettle();

    expect(find.byType(LookupResultsView), findsNothing);
    expect(find.text('open results'), findsOneWidget);
  });
}
