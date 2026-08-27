/// A vehicle matched by the fault lookup search.
///
/// [name] is the trim/generation label shown next to [brand]/[model] (e.g.
/// `Polo 6N1`). [fuelType] is stored as raw data, not localized copy.
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
}
