import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/domain/models/saved_vehicle.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/features/lookup/views/lookup_results_view.dart';
import 'package:car_faults_app/ui/features/profile/views/widgets/profile_saved_vehicle_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const _vehicle = SavedVehicle(
  id: 'vw-polo-6n1',
  brand: 'Volkswagen',
  model: 'Polo',
  name: 'Polo 6N1',
  yearFrom: 1994,
  yearTo: 1999,
  knownIssuesCount: 3,
);

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
      home: const Scaffold(body: ProfileSavedVehicleRow(vehicle: _vehicle)),
    ),
  );
}

void main() {
  testWidgets('shows the vehicle name, year range and issues pill', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(find.text('Volkswagen Polo 6N1'), findsOneWidget);
    expect(find.text('1994–1999'), findsOneWidget);
    expect(find.text('3 defeitos'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Ver detalhes de Volkswagen Polo'),
      findsOneWidget,
    );
  });

  testWidgets('tapping the row pushes LookupResultsView', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    await tester.tap(find.byType(ProfileSavedVehicleRow));
    await tester.pumpAndSettle();

    expect(find.byType(LookupResultsView), findsOneWidget);
  });
}
