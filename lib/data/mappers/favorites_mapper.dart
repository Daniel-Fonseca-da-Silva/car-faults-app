import '../../domain/models/favorite_vehicle.dart';

/// Maps one `items[]` entry of `GET /v1/activity-logs/favorites`
/// (`FavoriteVehicleResponseDto` JSON) to [FavoriteVehicle].
FavoriteVehicle mapFavoriteVehicle(Map<String, dynamic> json) {
  return FavoriteVehicle(
    vehicleModelId: json['vehicleModelId'] as String,
    brand: json['brand'] as String,
    model: json['model'] as String,
    year: json['year'] as int,
    engine: json['engine'] as String,
    fuelType: json['fuelType'] as String?,
    doors: json['doors'] as int?,
    imageUrl: json['imageUrl'] as String?,
  );
}
