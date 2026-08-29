import 'package:flutter/foundation.dart';

import '../../../../domain/models/known_issue.dart';
import '../../../../domain/models/saved_vehicle.dart';
import '../garage_demo_display.dart';

/// Owns the garage's saved vehicles and the known issues of the currently
/// selected one.
class GarageViewModel extends ChangeNotifier {
  GarageViewModel({List<SavedVehicle>? vehicles, List<KnownIssue>? issues})
    : _vehicles = List.of(vehicles ?? GarageDemoDisplay.vehicles),
      _issues = issues ?? GarageDemoDisplay.issues;

  final List<SavedVehicle> _vehicles;
  final List<KnownIssue> _issues;

  List<SavedVehicle> get vehicles => List.unmodifiable(_vehicles);

  SavedVehicle? get selectedVehicle =>
      _vehicles.isEmpty ? null : _vehicles.first;

  List<KnownIssue> get issues => selectedVehicle == null ? [] : _issues;

  void removeVehicle(String id) {
    _vehicles.removeWhere((vehicle) => vehicle.id == id);
    notifyListeners();
  }
}
