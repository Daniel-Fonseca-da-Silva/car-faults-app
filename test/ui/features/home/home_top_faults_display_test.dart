import 'package:car_faults_app/ui/features/home/home_top_faults_display.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatReportCount', () {
    test('adds no separator below one thousand', () {
      expect(formatReportCount(974), '974');
    });

    test('adds a single thousands separator', () {
      expect(formatReportCount(1842), '1.842');
    });

    test('adds a thousands separator for a round thousand', () {
      expect(formatReportCount(2310), '2.310');
    });
  });
}
