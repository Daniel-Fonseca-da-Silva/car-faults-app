import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:car_faults_app/domain/models/platform_stats.dart';
import 'package:car_faults_app/domain/models/top_fault.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PlatformStats holds the three public counts', () {
    const stats = PlatformStats(
      reportsCount: 1,
      vehiclesCount: 2,
      faultsCount: 3,
    );

    expect(stats.reportsCount, 1);
    expect(stats.vehiclesCount, 2);
    expect(stats.faultsCount, 3);
  });

  test('TopFault holds ranking fields and vehicle context', () {
    const fault = TopFault(
      id: 'f1',
      title: 'Oil leak',
      severity: IssueSeverity.high,
      reportCount: 9,
      vehicleBrand: 'Audi',
      vehicleModel: 'A3',
      vehicleYearFrom: 2015,
    );

    expect(fault.id, 'f1');
    expect(fault.title, 'Oil leak');
    expect(fault.severity, IssueSeverity.high);
    expect(fault.reportCount, 9);
    expect(fault.vehicleBrand, 'Audi');
    expect(fault.vehicleModel, 'A3');
    expect(fault.vehicleYearFrom, 2015);
  });
}
