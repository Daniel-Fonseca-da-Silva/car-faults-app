import 'issue_severity.dart';

/// One entry of the platform's most-reported-faults ranking, with just
/// enough vehicle context to identify it on the home screen.
class TopFault {
  const TopFault({
    required this.id,
    required this.title,
    required this.severity,
    required this.reportCount,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.vehicleYearFrom,
  });

  final String id;
  final String title;
  final IssueSeverity severity;
  final int reportCount;
  final String vehicleBrand;
  final String vehicleModel;
  final int vehicleYearFrom;
}
