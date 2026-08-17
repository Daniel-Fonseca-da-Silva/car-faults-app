const minLineCoveragePercent = 90.0;

class LineCoverage {
  const LineCoverage({required this.linesFound, required this.linesHit});

  final int linesFound;
  final int linesHit;

  double get percent {
    if (linesFound == 0) {
      return 0;
    }
    return (linesHit / linesFound) * 100;
  }

  bool meetsMinimum(double minimumPercent) => percent >= minimumPercent;
}

LineCoverage parseLcov(String source) {
  var linesFound = 0;
  var linesHit = 0;

  for (final line in source.split('\n')) {
    linesFound += _metricValue(line, 'LF:');
    linesHit += _metricValue(line, 'LH:');
  }

  return LineCoverage(linesFound: linesFound, linesHit: linesHit);
}

int _metricValue(String line, String prefix) {
  if (!line.startsWith(prefix)) {
    return 0;
  }
  return int.parse(line.substring(prefix.length));
}
