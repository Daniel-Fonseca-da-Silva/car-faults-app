import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/domain/models/saved_vehicle.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
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
  engine: '1.4',
);

Widget _app({VoidCallback? onTap, bool isLoading = false}) {
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
      home: Scaffold(
        body: ProfileSavedVehicleRow(
          vehicle: _vehicle,
          onTap: onTap ?? () {},
          isLoading: isLoading,
        ),
      ),
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

  testWidgets('tapping the row calls onTap', (WidgetTester tester) async {
    var tapped = false;
    await tester.pumpWidget(_app(onTap: () => tapped = true));

    await tester.tap(find.byType(ProfileSavedVehicleRow));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('shows a spinner instead of the chevron while loading', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(isLoading: true));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('ignores taps while loading', (WidgetTester tester) async {
    var tapped = false;
    await tester.pumpWidget(_app(onTap: () => tapped = true, isLoading: true));

    await tester.tap(find.byType(ProfileSavedVehicleRow));
    await tester.pump();

    expect(tapped, isFalse);
  });
}
