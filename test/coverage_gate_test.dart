import 'package:flutter_test/flutter_test.dart';

import '../tool/coverage_gate.dart';

void main() {
  test('parseLcov sums LF and LH records from multiple files', () {
    const source = '''
SF:lib/a.dart
LF:10
LH:9
end_of_record
SF:lib/b.dart
LF:10
LH:9
end_of_record
''';

    final coverage = parseLcov(source);

    expect(coverage.linesFound, 20);
    expect(coverage.linesHit, 18);
    expect(coverage.percent, 90);
  });

  test('parseLcov skips generated AppLocalizations files', () {
    const source = '''
SF:lib/l10n/app_localizations.dart
LF:19
LH:15
end_of_record
SF:lib/l10n/app_localizations_en.dart
LF:6
LH:0
end_of_record
SF:lib/l10n/app_localizations_es.dart
LF:6
LH:0
end_of_record
SF:lib/main.dart
LF:10
LH:9
end_of_record
''';

    final coverage = parseLcov(source);

    expect(coverage.linesFound, 10);
    expect(coverage.linesHit, 9);
    expect(coverage.percent, 90);
  });

  test('parseLcov returns zero coverage when the report is empty', () {
    final coverage = parseLcov('');

    expect(coverage.linesFound, 0);
    expect(coverage.linesHit, 0);
    expect(coverage.percent, 0);
  });

  test('meetsMinimum is true at the 90% threshold', () {
    const coverage = LineCoverage(linesFound: 10, linesHit: 9);

    expect(coverage.meetsMinimum(minLineCoveragePercent), isTrue);
  });

  test('meetsMinimum is false below the 90% threshold', () {
    const coverage = LineCoverage(linesFound: 10, linesHit: 8);

    expect(coverage.meetsMinimum(minLineCoveragePercent), isFalse);
  });
}
