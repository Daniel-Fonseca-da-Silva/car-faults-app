/// A vehicle matched by the fault lookup search.
///
/// [name] is the trim/generation label shown next to [brand]/[model] (e.g.
/// `Polo 6N1`). [fuelType] is stored as raw data, not localized copy.
/// [imageUrl] may be `null` when the vehicle model has no photo on record,
/// in which case the UI falls back to a placeholder image.
class LookupVehicle {
  const LookupVehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.name,
    required this.yearFrom,
    required this.yearTo,
    required this.engine,
    required this.doors,
    required this.fuelType,
    required this.powerHp,
    this.imageUrl,
  });

  final String id;
  final String brand;
  final String model;
  final String name;
  final int yearFrom;
  final int yearTo;
  final String engine;
  final int doors;
  final String fuelType;
  final int powerHp;
  final String? imageUrl;

  /// Production years as shown in the tech specs tile: a single year when
  /// [yearFrom] and [yearTo] match (e.g. `2015`), otherwise a range (e.g.
  /// `2015 - 2018`). Mirrors the web app's `formatYearRange`.
  String get yearRangeLabel =>
      yearFrom == yearTo ? '$yearFrom' : '$yearFrom - $yearTo';
}
