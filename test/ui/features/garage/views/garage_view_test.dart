import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/features/garage/view_models/garage_view_model.dart';
import 'package:car_faults_app/ui/features/garage/views/garage_view.dart';
import 'package:car_faults_app/ui/features/garage/views/widgets/garage_hero_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _app({GarageViewModel? viewModel}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => LocaleViewModel(
          repository: LocaleRepository(service: LocalePreferencesService()),
        ),
      ),
      ChangeNotifierProvider.value(value: viewModel ?? GarageViewModel()),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const GarageView(),
    ),
  );
}

void main() {
  testWidgets('shows the footer disclaimer', (WidgetTester tester) async {
    await tester.pumpWidget(_app());

    expect(
      find.text(
        'Dados obtidos de relatos públicos e entidades reguladoras. '
        'Não substitui uma avaliação técnica.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('default view model shows the demo vehicle in the hero', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(
      find.descendant(
        of: find.byType(GarageHeroCard),
        matching: find.text('Fiat Punto'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('empty view model shows the empty hero title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(viewModel: GarageViewModel(vehicles: [])));

    expect(find.text('A sua garagem está vazia'), findsOneWidget);
  });

  testWidgets(
    'removing the only vehicle empties the hero and the favourites list',
    (WidgetTester tester) async {
      await tester.pumpWidget(_app());

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      expect(find.text('A sua garagem está vazia'), findsOneWidget);
      expect(find.text('Ainda não tem veículos na garagem.'), findsOneWidget);
      expect(find.text('Fiat Punto'), findsNothing);
    },
  );

  testWidgets('default view model shows the known issues section', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(find.text('DEFEITOS CONHECIDOS'), findsOneWidget);
    expect(find.text('Timing belt wear and failure'), findsOneWidget);
  });

  testWidgets('removing the only vehicle hides the known issues section', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();

    expect(find.text('DEFEITOS CONHECIDOS'), findsNothing);
  });
}
