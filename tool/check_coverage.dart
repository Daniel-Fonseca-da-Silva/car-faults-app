import 'dart:io';

import 'coverage_gate.dart';

void main() {
  const reportPath = 'coverage/lcov.info';
  final file = File(reportPath);
  if (!file.existsSync()) {
    stderr.writeln('Missing $reportPath. Run: flutter test --coverage');
    exit(1);
  }

  final coverage = parseLcov(file.readAsStringSync());
  stdout.writeln(
    'Line coverage: ${coverage.percent.toStringAsFixed(2)}% '
    '(${coverage.linesHit}/${coverage.linesFound}). '
    'Minimum: $minLineCoveragePercent%.',
  );

  if (coverage.linesFound == 0) {
    stderr.writeln('No coverage data found.');
    exit(1);
  }

  if (coverage.meetsMinimum(minLineCoveragePercent)) {
    return;
  }

  stderr.writeln('Coverage is below $minLineCoveragePercent%.');
  exit(1);
}
