import 'package:car_faults_app/domain/models/lookup_vehicle.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/constants/app_assets.dart';
import 'package:car_faults_app/ui/features/lookup/view_models/lookup_results_view_model.dart';
import 'package:car_faults_app/ui/features/lookup/views/widgets/lookup_vehicle_hero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _app({LookupVehicle? vehicle}) {
  return ChangeNotifierProvider(
    create: (_) => LookupResultsViewModel(vehicle: vehicle),
    child: const MaterialApp(
      locale: Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: LookupVehicleHero()),
    ),
  );
}

const _vehicleWithPhoto = LookupVehicle(
  id: 'vw-polo-6n1',
  brand: 'Volkswagen',
  model: 'Polo',
  name: 'Polo 6N1',
  yearFrom: 1994,
  yearTo: 1999,
  engine: '1.6',
  doors: 4,
  fuelType: 'gasoline',
  powerHp: 101,
  imageUrl: 'https://cdn.example.com/vehicles/polo.jpg',
);

void main() {
  testWidgets('shows the eyebrow, vehicle name and model', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(find.text('VEÍCULO ENCONTRADO'), findsOneWidget);
    expect(find.text('Volkswagen Polo'), findsOneWidget);
    expect(find.text('Polo 6N1'), findsOneWidget);
  });

  testWidgets('uses the hero photo asset when the vehicle has no imageUrl', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, AppAssets.citroen2Cv);
  });

  testWidgets('loads the vehicle photo from the network when imageUrl is set', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(vehicle: _vehicleWithPhoto));

    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as NetworkImage).url,
      'https://cdn.example.com/vehicles/polo.jpg',
    );
  });
}
