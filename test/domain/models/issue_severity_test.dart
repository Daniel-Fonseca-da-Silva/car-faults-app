import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('has exactly the four severity levels, from low to critical', () {
    expect(IssueSeverity.values, [
      IssueSeverity.low,
      IssueSeverity.medium,
      IssueSeverity.high,
      IssueSeverity.critical,
    ]);
  });
}
