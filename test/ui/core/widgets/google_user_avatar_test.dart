import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/widgets/google_user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) {
  return MaterialApp(
    locale: const Locale('pt'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('shows the initials when there is no photo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(const GoogleUserAvatar(name: 'Daniel Fonseca')),
    );

    expect(find.text('DF'), findsOneWidget);
  });

  testWidgets('falls back to "?" for a blank name', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(const GoogleUserAvatar(name: '   ')));

    expect(find.text('?'), findsOneWidget);
  });

  testWidgets('uses the network photo and hides initials when given a URL', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const GoogleUserAvatar(
          name: 'Daniel Fonseca',
          photoUrl: 'https://example.com/photo.png',
        ),
      ),
    );

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundImage, isA<NetworkImage>());
    expect(find.text('DF'), findsNothing);
  });

  testWidgets('defaults to a 40dp diameter', (WidgetTester tester) async {
    await tester.pumpWidget(_app(const GoogleUserAvatar(name: 'Ana Silva')));

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.radius, GoogleUserAvatar.defaultSize / 2);
  });

  testWidgets('uses the given size when provided', (WidgetTester tester) async {
    await tester.pumpWidget(
      _app(const GoogleUserAvatar(name: 'Ana Silva', size: 64)),
    );

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.radius, 32);
  });

  testWidgets('shows initials when the photo fails to load', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const GoogleUserAvatar(
          name: 'Daniel Fonseca',
          photoUrl: 'https://example.com/photo.png',
        ),
      ),
    );
    await tester.pump();

    expect(find.text('DF'), findsOneWidget);
    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundImage, isNull);
  });
}
