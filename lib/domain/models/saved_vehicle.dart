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

  /// Builds a [SavedVehicle] from `car-faults-api`'s `UserVehicleResponseDto`
  /// JSON.
  ///
  /// The API reports a single [year]; this app's model splits it into
  /// [yearFrom]/[yearTo] to match [name]'s year-range display, so both are
  /// set to the same value. [name] falls back to `'brand model'` when the
  /// API's is `null` (never named by the owner).
  factory SavedVehicle.fromUserVehicleJson(Map<String, dynamic> json) {
    final brand = json['brand'] as String;
    final model = json['model'] as String;
    final year = json['year'] as int;

    return SavedVehicle(
      id: json['id'] as String,
      brand: brand,
      model: model,
      name: (json['name'] as String?) ?? '$brand $model',
      yearFrom: year,
      yearTo: year,
      knownIssuesCount: json['knownIssuesCount'] as int,
    );
  }

  final String id;
  final String brand;
  final String model;
  final String name;
  final int yearFrom;
  final int yearTo;
  final int knownIssuesCount;
}
