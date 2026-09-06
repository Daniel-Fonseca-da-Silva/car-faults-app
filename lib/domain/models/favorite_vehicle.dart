/// A vehicle the user favorited from a fault lookup, shown on the favorites
/// screen.
class FavoriteVehicle {
  const FavoriteVehicle({
    required this.vehicleModelId,
    required this.brand,
    required this.model,
    required this.year,
    required this.engine,
    required this.fuelType,
    required this.doors,
    required this.imageUrl,
  });

  final String vehicleModelId;
  final String brand;
  final String model;
  final int year;
  final String engine;
  final String? fuelType;
  final int? doors;
  final String? imageUrl;
}
