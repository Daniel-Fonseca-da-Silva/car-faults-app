import 'package:car_faults_app/domain/models/saved_vehicle.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/constants/app_assets.dart';
import 'package:car_faults_app/ui/features/garage/views/widgets/garage_hero_card.dart';
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

Widget _app({SavedVehicle? selectedVehicle}) {
  return MaterialApp(
    locale: const Locale('pt'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: GarageHeroCard(selectedVehicle: selectedVehicle)),
  );
}

void main() {
  testWidgets('empty garage shows the empty title and no year', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(find.text('A sua garagem está vazia'), findsOneWidget);
    expect(find.text('2001'), findsNothing);
  });

  testWidgets('selected vehicle shows its name and year', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(selectedVehicle: _vehicle));

    expect(find.text('Fiat Punto'), findsOneWidget);
    expect(find.text('2001'), findsOneWidget);
    expect(find.text('A sua garagem está vazia'), findsNothing);
  });

  testWidgets('shows the eyebrow label', (WidgetTester tester) async {
    await tester.pumpWidget(_app());

    expect(find.text('GARAGEM'), findsOneWidget);
  });

  testWidgets('uses the hero photo asset with its alt text', (
    WidgetTester tester,
  ) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(_app());

    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, AppAssets.garage);
    expect(
      find.bySemanticsLabel('Garagem com um Volkswagen Beetle clássico'),
      findsOneWidget,
    );

    handle.dispose();
  });
}
