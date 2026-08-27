import 'package:car_faults_app/domain/models/app_locale.dart';
import 'package:car_faults_app/ui/core/widgets/locale_flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final locale in AppLocale.values) {
    testWidgets('renders without error for ${locale.languageCode}', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LocaleFlag(locale: locale)),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  }
}
