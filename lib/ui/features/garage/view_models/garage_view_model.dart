import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/mappers/lookup_mapper.dart';
import '../../../../data/repositories/garage_repository.dart';
import '../../../../data/repositories/lookup_repository.dart';
import '../../../../domain/models/app_locale.dart';
import '../../../../domain/models/known_issue.dart';
import '../../../../domain/models/saved_vehicle.dart';
import '../../home/home_search_options.dart';

/// Owns the garage's saved vehicles, loaded from [GarageRepository], and the
/// known issues of the currently selected one — the first vehicle by
/// default, or whichever one [selectVehicle] last picked.
///
/// [locale] is fixed for the ViewModel's lifetime (a fresh instance is
/// created each time the garage screen opens) and drives both the
/// known-issues language sent to [GarageRepository] and the vehicle re-lookup
/// in [openVehicle].
class GarageViewModel extends ChangeNotifier {
  GarageViewModel({
    required this.locale,
    GarageRepository? repository,
    LookupRepository? lookupRepository,
  }) : _repository = repository ?? GarageRepository(),
       _lookupRepository = lookupRepository ?? LookupRepository();

  final AppLocale locale;
  final GarageRepository _repository;
  final LookupRepository _lookupRepository;

  List<SavedVehicle> _vehicles = const [];
  List<SavedVehicle> get vehicles => List.unmodifiable(_vehicles);

  String? _selectedVehicleId;

  /// The vehicle highlighted in the hero card and known-issues section:
  /// [_selectedVehicleId] when it still exists in [_vehicles], falling back
  /// to the first vehicle otherwise (initial load, or after the selected
  /// vehicle was removed).
  SavedVehicle? get selectedVehicle {
    if (_vehicles.isEmpty) return null;
    return _vehicles.firstWhere(
      (vehicle) => vehicle.id == _selectedVehicleId,
      orElse: () => _vehicles.first,
    );
  }

  List<KnownIssue> _issues = const [];
  List<KnownIssue> get issues => selectedVehicle == null ? [] : _issues;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  bool _removeFailed = false;
  bool get removeFailed => _removeFailed;

  /// `GET /v1/user-vehicles`. On success, kicks off a background fetch of
  /// the first vehicle's known issues via [_loadIssuesFor].
  Future<void> load() async {
    if (_isLoading) return;

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    final vehicles = await _repository.fetchVehicles(locale: locale);

    _isLoading = false;
    if (vehicles == null) {
      _hasError = true;
      notifyListeners();
      return;
    }

    _vehicles = vehicles;
    notifyListeners();

    final selected = selectedVehicle;
    if (selected != null) {
      unawaited(_loadIssuesFor(selected.id));
    }
  }

  Future<void> _loadIssuesFor(String vehicleId) async {
    final issues = await _repository.fetchKnownIssues(
      vehicleId,
      locale: locale,
    );
    if (issues == null || selectedVehicle?.id != vehicleId) return;

    _issues = issues;
    notifyListeners();
  }

  /// Highlights [id] in the hero card and loads its known issues. No-op if
  /// [id] is already the selected vehicle.
  void selectVehicle(String id) {
    if (id == selectedVehicle?.id) return;

    _selectedVehicleId = id;
    _issues = const [];
    notifyListeners();
    unawaited(_loadIssuesFor(id));
  }

  /// `DELETE /v1/user-vehicles/:id`. Sets [removeFailed] instead of leaving
  /// the vehicle shown when the API call fails.
  Future<void> removeVehicle(String id) async {
    final wasSelected = selectedVehicle?.id == id;
    final removed = await _repository.removeVehicle(id);

    _removeFailed = !removed;
    if (!removed) {
      notifyListeners();
      return;
    }

    _vehicles = _vehicles.where((vehicle) => vehicle.id != id).toList();
    if (wasSelected) {
      _selectedVehicleId = null;
      _issues = const [];
      final next = selectedVehicle;
      if (next != null) unawaited(_loadIssuesFor(next.id));
    }
    notifyListeners();
  }

  /// Clears [removeFailed] once the View has shown it, so a rebuild doesn't
  /// show the same SnackBar again.
  void acknowledgeRemoveFailure() {
    _removeFailed = false;
  }

  String? _openingVehicleId;

  bool isOpeningVehicle(String vehicleId) => _openingVehicleId == vehicleId;

  LookupSearchResult? _pendingResult;

  /// Outcome of the last [openVehicle] call, consumed once by the View
  /// (which calls [acknowledgePendingResult] after handling it) to navigate
  /// to the real results screen or show an error.
  LookupSearchResult? get pendingResult => _pendingResult;

  int? _pendingSearchedYear;
  int? get pendingSearchedYear => _pendingSearchedYear;

  /// Looks up [vehicle] via `GET /v1/lookups` so its "View details" link
  /// opens the vehicle's real known issues instead of `LookupDemoDisplay`'s
  /// fixture data — [SavedVehicle] carries no reviews/fixes of its own,
  /// matching how [FavoritesViewModel] resolves a saved vehicle.
  Future<void> openVehicle(SavedVehicle vehicle) async {
    if (_openingVehicleId != null) return;

    _openingVehicleId = vehicle.id;
    notifyListeners();

    final fuel =
        (vehicle.fuelType == null
            ? null
            : fuelOptionFromApiValue(vehicle.fuelType!)) ??
        FuelOption.petrol;

    final result = await _lookupRepository.search(
      brand: vehicle.brand,
      model: vehicle.model,
      year: vehicle.yearFrom,
      engine: vehicle.engine,
      fuel: fuel,
      doors: vehicle.doors,
      locale: locale,
    );

    _openingVehicleId = null;
    _pendingResult = result;
    _pendingSearchedYear = vehicle.yearFrom;
    notifyListeners();
  }

  /// Clears [pendingResult] once the View has shown it, so a rebuild doesn't
  /// handle the same result again.
  void acknowledgePendingResult() {
    _pendingResult = null;
  }
}
