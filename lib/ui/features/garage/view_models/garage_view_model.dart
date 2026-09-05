import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/garage_repository.dart';
import '../../../../domain/models/known_issue.dart';
import '../../../../domain/models/saved_vehicle.dart';

/// Owns the garage's saved vehicles, loaded from [GarageRepository], and the
/// known issues of the currently selected one (always the first vehicle —
/// there is no selection UI in this slice).
class GarageViewModel extends ChangeNotifier {
  GarageViewModel({GarageRepository? repository})
    : _repository = repository ?? GarageRepository();

  final GarageRepository _repository;

  List<SavedVehicle> _vehicles = const [];
  List<SavedVehicle> get vehicles => List.unmodifiable(_vehicles);

  SavedVehicle? get selectedVehicle =>
      _vehicles.isEmpty ? null : _vehicles.first;

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

    final vehicles = await _repository.fetchVehicles();

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
    final issues = await _repository.fetchKnownIssues(vehicleId);
    if (issues == null || selectedVehicle?.id != vehicleId) return;

    _issues = issues;
    notifyListeners();
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
}
