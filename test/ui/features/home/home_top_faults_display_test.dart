import 'package:car_faults_app/ui/core/utils/format_count.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatCount', () {
    test('adds no separator below one thousand', () {
      expect(formatCount(974), '974');
    });

    test('adds a single thousands separator', () {
      expect(formatCount(1842), '1.842');
    });

    test('adds a thousands separator for a round thousand', () {
      expect(formatCount(2310), '2.310');
    });
  });
}
