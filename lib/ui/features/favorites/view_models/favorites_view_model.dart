import 'package:flutter/foundation.dart';

import '../../../../data/repositories/favorites_repository.dart';
import '../../../../domain/models/favorite_vehicle.dart';

/// Owns the favorites screen's favorited vehicles, loaded from
/// [FavoritesRepository].
class FavoritesViewModel extends ChangeNotifier {
  FavoritesViewModel({FavoritesRepository? repository})
    : _repository = repository ?? FavoritesRepository();

  final FavoritesRepository _repository;

  List<FavoriteVehicle> _vehicles = const [];
  List<FavoriteVehicle> get vehicles => List.unmodifiable(_vehicles);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  bool _removeFailed = false;
  bool get removeFailed => _removeFailed;

  /// `GET /v1/activity-logs/favorites` — first page only.
  Future<void> load() async {
    if (_isLoading) return;

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    final vehicles = await _repository.fetchFavorites();

    _isLoading = false;
    if (vehicles == null) {
      _hasError = true;
      notifyListeners();
      return;
    }

    _vehicles = vehicles;
    notifyListeners();
  }

  /// `DELETE /v1/activity-logs/favorites/:vehicleModelId`. Sets
  /// [removeFailed] instead of leaving the vehicle shown when the API call
  /// fails.
  Future<void> removeFavorite(FavoriteVehicle vehicle) async {
    final removed = await _repository.unfavorite(
      vehicleModelId: vehicle.vehicleModelId,
      year: vehicle.year,
    );

    _removeFailed = !removed;
    if (!removed) {
      notifyListeners();
      return;
    }

    _vehicles = _vehicles
        .where(
          (v) =>
              v.vehicleModelId != vehicle.vehicleModelId ||
              v.year != vehicle.year,
        )
        .toList();
    notifyListeners();
  }

  /// Clears [removeFailed] once the View has shown it, so a rebuild doesn't
  /// show the same SnackBar again.
  void acknowledgeRemoveFailure() {
    _removeFailed = false;
  }
}
