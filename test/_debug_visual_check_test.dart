import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:car_faults_app/main.dart';

void main() {
  testWidgets('debug: render LoginView to a PNG for manual visual check', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(780, 200);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CarFaultsApp());
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(CarFaultsApp),
      matchesGoldenFile('_debug_login_header.png'),
    );
  });
}
