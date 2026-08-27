/// A vehicle the user bookmarked from a fault lookup, shown on the profile
/// screen.
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
