import 'package:car_faults_app/domain/models/saved_vehicle.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/features/garage/views/widgets/garage_vehicles_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _vehicle = SavedVehicle(
  id: 'fiat-punto-2001',
  brand: 'Fiat',
  model: 'Punto',
  name: 'Punto',
  yearFrom: 2001,
  yearTo: 2001,
  knownIssuesCount: 3,
);

Widget _app({
  List<SavedVehicle> vehicles = const [],
  ValueChanged<String>? onRemoveVehicle,
}) {
  return MaterialApp(
    locale: const Locale('pt'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: GarageVehiclesSection(
        vehicles: vehicles,
        onRemoveVehicle: onRemoveVehicle ?? (_) {},
      ),
    ),
  );
}

void main() {
  testWidgets('shows the section title', (WidgetTester tester) async {
    await tester.pumpWidget(_app());

    expect(find.text('OS TEUS VEÍCULOS'), findsOneWidget);
  });

  testWidgets('empty list shows the empty message and no vehicle', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(find.text('Ainda não tem veículos na garagem.'), findsOneWidget);
    expect(find.text('Fiat Punto'), findsNothing);
  });

  testWidgets('filled list shows the vehicle name, year and issues pill', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(vehicles: const [_vehicle]));

    expect(find.text('Fiat Punto'), findsOneWidget);
    expect(find.text('2001'), findsOneWidget);
    expect(find.text('3 defeitos'), findsOneWidget);
  });

  testWidgets('tapping the delete icon calls onRemoveVehicle with the id', (
    WidgetTester tester,
  ) async {
    String? removedId;

    await tester.pumpWidget(
      _app(vehicles: const [_vehicle], onRemoveVehicle: (id) => removedId = id),
    );
    await tester.tap(find.byIcon(Icons.delete_outline));

    expect(removedId, 'fiat-punto-2001');
  });

  testWidgets('delete icon tooltip contains the vehicle name', (
    WidgetTester tester,
  ) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(_app(vehicles: const [_vehicle]));

    expect(
      find.bySemanticsLabel('Remover Fiat Punto da garagem'),
      findsOneWidget,
    );

    handle.dispose();
  });
}
