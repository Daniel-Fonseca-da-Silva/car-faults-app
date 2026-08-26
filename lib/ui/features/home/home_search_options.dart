import 'package:car_faults_app/l10n/app_localizations.dart';

/// Fuel types offered by the search form.
///
/// UI enum with en-GB naming, matching the web app's fuel list
/// (`gasoline`/`gpl` there, `petrol`/`lpg` here).
enum FuelOption { petrol, diesel, electric, lpg, hybrid }

extension FuelOptionLabel on FuelOption {
  String label(AppLocalizations l10n) => switch (this) {
    FuelOption.petrol => l10n.homeFuelPetrol,
    FuelOption.diesel => l10n.homeFuelDiesel,
    FuelOption.electric => l10n.homeFuelElectric,
    FuelOption.lpg => l10n.homeFuelLpg,
    FuelOption.hybrid => l10n.homeFuelHybrid,
  };
}

/// Mocked option lists of the vehicle search form.
///
/// [brands] and [doors] mirror the web app (`lib/mocks/vehicle-makes.ts` and
/// the door options of `components/home/vehicle-search-form.tsx`). A real
/// catalogue endpoint replaces this later.
abstract final class HomeSearchOptions {
  static const doors = <int>[2, 3, 4, 5];
  static const oldestYear = 1990;

  /// Newest first, down to [oldestYear]. Next year is included because models
  /// reach the market before their model year starts.
  static List<int> years() {
    final newestYear = DateTime.now().year + 1;
    return [for (var year = newestYear; year >= oldestYear; year--) year];
  }

  /// Case-insensitive substring match, same rule as the web app's
  /// `filterVehicleMakes`. An empty query offers every make.
  static List<String> filterBrands(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return brands;

    return [
      for (final brand in brands)
        if (brand.toLowerCase().contains(normalizedQuery)) brand,
    ];
  }

  static const brands = <String>[
    'AC Cars',
    'AGB IPA',
    'Aiways',
    'Aixam',
    'Alba',
    'Alpine',
    'Aprilia',
    'Arrinera',
    'Aston Martin',
    'Audi',
    'BEN',
    'Bentley',
    'BMW',
    'Brabham',
    'BYD',
    'Cadillac',
    'CFMOTO',
    'Changan',
    'Chevrolet',
    'Chrysler',
    'Citroën',
    'Cyclone Motor',
    'Dacia',
    'Dafra',
    'Derbi',
    'Deutz-Fahr',
    'DM',
    'Dodge',
    'Dongfeng',
    'Edfor',
    'Elfin',
    'Felcom',
    'Fendt',
    'Ferrari',
    'Fiat',
    'Ford',
    'FSO',
    'GMC',
    'Harley-Davidson',
    'Holden',
    'Honda',
    'Hyundai',
    'Indian',
    'Iveco',
    'Izera',
    'Jaguar',
    'Jeep',
    'John Deere',
    'Keeway',
    'Kia',
    'Lada',
    'Lamborghini',
    'Land Rover',
    'Ligier',
    'Lincoln',
    'Lotus',
    'Maserati',
    'Massey Ferguson',
    'Mazda',
    'Mercedes-Benz',
    'MG',
    'MGA',
    'Microcar',
    'Mini',
    'Mitsubishi',
    'Moto Guzzi',
    'New Holland',
    'Nissan',
    'Olda',
    'Opel',
    'Peugeot',
    'Piaggio',
    'Porsche',
    'Portaro',
    'QJ Motor',
    'Renault',
    'Rolls-Royce',
    'Sado',
    'SEAT',
    'Smart',
    'Solis',
    'Subaru',
    'Suzuki',
    'Syrena',
    'Tesla',
    'Toyota',
    'Triumph',
    'UMM',
    'Valtra',
    'Vauxhall',
    'Veeco',
    'Voge',
    'Volkswagen',
    'Volvo',
    'Yamaha',
    'Zontes',
  ];
}
