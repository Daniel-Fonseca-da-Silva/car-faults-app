import 'issue_severity.dart';

/// One entry of the platform's most-reported-faults ranking, with just
/// enough vehicle context to identify it on the home screen or defects list.
class TopFault {
  const TopFault({
    required this.id,
    required this.title,
    required this.severity,
    required this.reportCount,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.vehicleYearFrom,
    this.vehicleEngine,
    this.vehicleFuelType,
    this.vehicleDoors,
  });

  final String id;
  final String title;
  final IssueSeverity severity;
  final int reportCount;
  final String vehicleBrand;
  final String vehicleModel;
  final int vehicleYearFrom;

  /// Omitted fields mirror `TopFaultVehicleDto`: [vehicleFuelType] and
  /// [vehicleDoors] are absent when the vehicle model has none on record,
  /// same as the web app — used to gate whether a fault can be opened as a
  /// full lookup (see `DefectsViewModel.openVehicle`).
  final String? vehicleEngine;
  final String? vehicleFuelType;
  final int? vehicleDoors;
}
