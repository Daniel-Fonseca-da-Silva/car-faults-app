/// Vehicle saved by the user, shown in the profile's saved-vehicles list.
class SavedVehicle {
  const SavedVehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.name,
    required this.yearFrom,
    required this.yearTo,
    required this.knownIssuesCount,
  });

  final String id;
  final String brand;
  final String model;
  final String name;
  final int yearFrom;
  final int yearTo;
  final int knownIssuesCount;
}
