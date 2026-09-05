import 'package:car_faults_app/ui/core/utils/format_count.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatCount', () {
    test('adds no separator below one thousand', () {
      expect(formatCount(0), '0');
      expect(formatCount(974), '974');
    });

    test('adds a single thousands separator', () {
      expect(formatCount(1000), '1.000');
      expect(formatCount(1842), '1.842');
    });

    test('adds separators for larger counts', () {
      expect(formatCount(2310), '2.310');
      expect(formatCount(1200000), '1.200.000');
    });
  });
}
