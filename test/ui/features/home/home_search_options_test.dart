import 'dart:ui' show Locale;

import 'package:car_faults_app/ui/features/home/home_search_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeSearchOptions.fuelsFor', () {
    test('offers flex and ethanol for pt_BR', () {
      expect(HomeSearchOptions.fuelsFor(const Locale('pt', 'BR')), [
        FuelOption.petrol,
        FuelOption.flex,
        FuelOption.ethanol,
        FuelOption.diesel,
        FuelOption.electric,
        FuelOption.lpg,
        FuelOption.hybrid,
      ]);
    });

    test('leaves flex and ethanol out for every other locale', () {
      for (final locale in const [
        Locale('pt'),
        Locale('en'),
        Locale('es'),
        Locale('fr'),
      ]) {
        expect(HomeSearchOptions.fuelsFor(locale), [
          FuelOption.petrol,
          FuelOption.diesel,
          FuelOption.electric,
          FuelOption.lpg,
          FuelOption.hybrid,
        ], reason: '$locale');
      }
    });
  });
}
