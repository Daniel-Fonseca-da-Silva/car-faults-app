import 'package:flutter/foundation.dart';

import '../../../../data/mappers/lookup_mapper.dart';
import '../../../../data/repositories/favorites_repository.dart';
import '../../../../data/repositories/lookup_repository.dart';
import '../../../../domain/models/app_locale.dart';
import '../../../../domain/models/favorite_vehicle.dart';
import '../../home/home_search_options.dart';

/// Owns the favorites screen's favorited vehicles, loaded from
/// [FavoritesRepository], and opening one of them via [LookupRepository].
class FavoritesViewModel extends ChangeNotifier {
  FavoritesViewModel({
    FavoritesRepository? repository,
    LookupRepository? lookupRepository,
  }) : _repository = repository ?? FavoritesRepository(),
       _lookupRepository = lookupRepository ?? LookupRepository();

  final FavoritesRepository _repository;
  final LookupRepository _lookupRepository;

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

  String? _openingVehicleModelId;

  bool isOpeningVehicle(String vehicleModelId) =>
      _openingVehicleModelId == vehicleModelId;

  LookupSearchResult? _pendingResult;

  /// Outcome of the last [openVehicle] call, consumed once by the View
  /// (which calls [acknowledgePendingResult] after handling it) to
  /// navigate to the results screen or show an error.
  LookupSearchResult? get pendingResult => _pendingResult;

  int? _pendingSearchedYear;
  int? get pendingSearchedYear => _pendingSearchedYear;

  /// Looks up [vehicle] via `GET /v1/lookups` (the same call the home
  /// screen's search uses), keyed by its brand/model/year/engine/fuel
  /// type/doors — [FavoriteVehicle] carries no catalog id to look it up by,
  /// matching how the web app resolves a favorite to its details page.
  Future<void> openVehicle(
    FavoriteVehicle vehicle, {
    required AppLocale locale,
  }) async {
    if (_openingVehicleModelId != null) return;

    _openingVehicleModelId = vehicle.vehicleModelId;
    notifyListeners();

    final fuel =
        (vehicle.fuelType == null
            ? null
            : fuelOptionFromApiValue(vehicle.fuelType!)) ??
        FuelOption.petrol;

    final result = await _lookupRepository.search(
      brand: vehicle.brand,
      model: vehicle.model,
      year: vehicle.year,
      engine: vehicle.engine,
      fuel: fuel,
      doors: vehicle.doors,
      locale: locale,
    );

    _openingVehicleModelId = null;
    _pendingResult = result;
    _pendingSearchedYear = vehicle.year;
    notifyListeners();
  }

  /// Clears [pendingResult] once the View has shown it, so a rebuild
  /// doesn't handle the same result again.
  void acknowledgePendingResult() {
    _pendingResult = null;
  }
}
