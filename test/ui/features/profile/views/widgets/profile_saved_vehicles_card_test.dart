import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/domain/models/saved_vehicle.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/features/lookup/views/lookup_results_view.dart';
import 'package:car_faults_app/ui/features/profile/profile_demo_display.dart';
import 'package:car_faults_app/ui/features/profile/views/widgets/profile_saved_vehicle_row.dart';
import 'package:car_faults_app/ui/features/profile/views/widgets/profile_saved_vehicles_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _app(List<SavedVehicle> vehicles) {
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
      home: Scaffold(body: ProfileSavedVehiclesCard(vehicles: vehicles)),
    ),
  );
}

void main() {
  testWidgets(
    'shows the vehicle count, rows and issue badges from the demo snapshot',
    (WidgetTester tester) async {
      await tester.pumpWidget(_app(ProfileDemoDisplay.snapshot.vehicles));

      expect(find.text('OS MEUS VEÍCULOS'), findsOneWidget);
      expect(find.text('3 veículos'), findsOneWidget);
      expect(find.byType(ProfileSavedVehicleRow), findsNWidgets(3));

      expect(find.text('Volkswagen Polo 6N1'), findsOneWidget);
      expect(find.text('1994–1999'), findsOneWidget);
      expect(find.text('3 defeitos'), findsOneWidget);

      expect(find.text('Fiat Uno Mille'), findsOneWidget);
      expect(find.text('2005–2010'), findsOneWidget);
      expect(find.text('5 defeitos'), findsOneWidget);

      expect(find.text('Ford Fiesta'), findsOneWidget);
      expect(find.text('2011–2014'), findsOneWidget);
      expect(find.text('2 defeitos'), findsOneWidget);
    },
  );

  testWidgets('shows the empty state when there are no saved vehicles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(const []));

    expect(find.text('Ainda não tem nenhum veículo.'), findsOneWidget);
    expect(find.text('0 veículos'), findsOneWidget);
    expect(find.byType(ProfileSavedVehicleRow), findsNothing);
  });

  testWidgets('tapping a row pushes LookupResultsView', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(ProfileDemoDisplay.snapshot.vehicles));

    await tester.tap(find.text('Volkswagen Polo 6N1'));
    await tester.pumpAndSettle();

    expect(find.byType(LookupResultsView), findsOneWidget);
  });
}
