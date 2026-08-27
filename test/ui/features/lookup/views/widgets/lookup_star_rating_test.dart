import 'package:car_faults_app/ui/features/lookup/views/widgets/lookup_star_rating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('read-only mode rounds the value to the nearest whole star', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LookupStarRating(value: 4.3))),
    );

    expect(find.byIcon(Icons.star), findsNWidgets(4));
    expect(find.byIcon(Icons.star_border), findsNWidgets(1));
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('interactive mode reports the tapped star index', (
    WidgetTester tester,
  ) async {
    int? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LookupStarRating(
            value: 0,
            onChanged: (value) => tapped = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(IconButton).at(3));

    expect(tapped, 4);
  });
}
