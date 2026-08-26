import 'package:car_faults_app/l10n/app_localizations.dart';

/// Mocked entry of the "most reported faults" list.
///
/// Placeholder data: there is no data source in this delivery.
class TopFaultEntry {
  const TopFaultEntry({
    required this.brand,
    required this.model,
    required this.year,
    required this.reportCount,
    required this.faultDescription,
  });

  final String brand;
  final String model;
  final int year;
  final int reportCount;

  /// Resolves the localized fault description for the active locale.
  final String Function(AppLocalizations l10n) faultDescription;
}

String _faultInjection(AppLocalizations l10n) => l10n.homeFaultInjection;
String _faultBodyCorrosion(AppLocalizations l10n) =>
    l10n.homeFaultBodyCorrosion;
String _faultEngineCoverLeak(AppLocalizations l10n) =>
    l10n.homeFaultEngineCoverLeak;
String _faultRearBrakeWear(AppLocalizations l10n) =>
    l10n.homeFaultRearBrakeWear;
String _faultGearboxIntermittent(AppLocalizations l10n) =>
    l10n.homeFaultGearboxIntermittent;
String _faultDashElectrical(AppLocalizations l10n) =>
    l10n.homeFaultDashElectrical;

/// Mocked "most reported faults" shown on the home screen.
///
/// Placeholder data: there is no data source in this delivery.
abstract final class HomeTopFaultsDisplay {
  static const entries = <TopFaultEntry>[
    TopFaultEntry(
      brand: 'Volkswagen',
      model: 'Gol',
      year: 2015,
      reportCount: 1842,
      faultDescription: _faultInjection,
    ),
    TopFaultEntry(
      brand: 'Fiat',
      model: 'Uno',
      year: 2012,
      reportCount: 2310,
      faultDescription: _faultBodyCorrosion,
    ),
    TopFaultEntry(
      brand: 'Ford',
      model: 'EcoSport',
      year: 2018,
      reportCount: 974,
      faultDescription: _faultEngineCoverLeak,
    ),
    TopFaultEntry(
      brand: 'Toyota',
      model: 'Corolla',
      year: 2017,
      reportCount: 563,
      faultDescription: _faultRearBrakeWear,
    ),
    TopFaultEntry(
      brand: 'Chevrolet',
      model: 'Onix',
      year: 2020,
      reportCount: 1207,
      faultDescription: _faultGearboxIntermittent,
    ),
    TopFaultEntry(
      brand: 'Renault',
      model: 'Sandero',
      year: 2016,
      reportCount: 788,
      faultDescription: _faultDashElectrical,
    ),
  ];
}

/// Formats a report count with a `.` thousands separator, e.g. `1842` ->
/// `'1.842'`. Fixed across locales, matching the badge copy in the mockups.
String formatReportCount(int count) {
  final digits = count.toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }

  return buffer.toString();
}
