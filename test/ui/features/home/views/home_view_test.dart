import 'dart:async';

import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/main.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/core/widgets/app_footer.dart';
import 'package:car_faults_app/ui/core/widgets/app_header.dart';
import 'package:car_faults_app/ui/core/widgets/app_menu_button.dart';
import 'package:car_faults_app/ui/core/widgets/brand_wordmark.dart';
import 'package:car_faults_app/ui/features/home/view_models/home_search_view_model.dart';
import 'package:car_faults_app/ui/features/home/views/home_view.dart';
import 'package:car_faults_app/ui/features/home/views/widgets/home_search_card.dart';
import 'package:car_faults_app/ui/features/login/views/login_view.dart';
import 'package:car_faults_app/ui/features/lookup/views/lookup_results_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _homeApp({required HomeSearchViewModel viewModel}) {
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
      home: HomeView(viewModel: viewModel),
    ),
  );
}

Future<void> _tapSearch(WidgetTester tester) async {
  final button = find.descendant(
    of: find.byType(HomeSearchCard),
    matching: find.text('Pesquisar defeitos'),
  );
  await tester.ensureVisible(button);
  await tester.tap(button);
}

void main() {
  testWidgets('HomeView shows AppHeader and AppFooter', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(CarFaultsApp());

    expect(
      find.descendant(
        of: find.byType(AppHeader),
        matching: find.byType(BrandWordmark),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(AppFooter),
        matching: find.byType(BrandWordmark),
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Dados obtidos de relatos públicos e entidades reguladoras. '
        'Não substitui uma avaliação técnica.',
      ),
      findsOneWidget,
    );
    expect(find.text('© 2026'), findsOneWidget);
  });

  testWidgets('HomeView shows the vehicle search card', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(CarFaultsApp());

    expect(find.byType(HomeSearchCard), findsOneWidget);
    expect(find.text('PESQUISAR VEÍCULO'), findsOneWidget);
  });

  testWidgets('opening the menu and tapping Entrar opens the LoginView', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(CarFaultsApp());

    await tester.tap(find.byType(AppMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.text('Entrar na conta'), findsOneWidget);
  });

  testWidgets('searching shows the loading copy until results open', (
    WidgetTester tester,
  ) async {
    final gate = Completer<void>();
    final viewModel = HomeSearchViewModel(delay: (_) => gate.future)
      ..setModel('Polo');

    await tester.pumpWidget(_homeApp(viewModel: viewModel));
    await _tapSearch(tester);
    await tester.pump();

    expect(find.text('A pesquisar…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(HomeSearchCard), findsNothing);

    gate.complete();
    await tester.pumpAndSettle();

    expect(find.byType(LookupResultsView), findsOneWidget);
    expect(find.text('Nova busca'), findsOneWidget);
  });

  testWidgets('search with an instant delay pushes LookupResultsView', (
    WidgetTester tester,
  ) async {
    final viewModel = HomeSearchViewModel(delay: (_) => Future<void>.value())
      ..setYear(1996);

    await tester.pumpWidget(_homeApp(viewModel: viewModel));
    await _tapSearch(tester);
    await tester.pumpAndSettle();

    expect(find.byType(LookupResultsView), findsOneWidget);
  });
}
