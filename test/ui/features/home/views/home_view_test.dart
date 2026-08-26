import 'package:car_faults_app/main.dart';
import 'package:car_faults_app/ui/core/widgets/app_footer.dart';
import 'package:car_faults_app/ui/core/widgets/app_header.dart';
import 'package:car_faults_app/ui/core/widgets/brand_wordmark.dart';
import 'package:car_faults_app/ui/features/home/views/widgets/home_search_card.dart';
import 'package:car_faults_app/ui/features/login/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HomeView shows AppHeader and AppFooter', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CarFaultsApp());

    expect(
      find.descendant(
        of: find.byType(AppHeader),
        matching: find.byType(BrandWordmark),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(AppFooter),
        matching: find.byType(BrandWordmark),
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Dados obtidos de relatos públicos e entidades reguladoras. '
        'Não substitui uma avaliação técnica.',
      ),
      findsOneWidget,
    );
    expect(find.text('© 2026'), findsOneWidget);
  });

  testWidgets('HomeView shows the vehicle search card', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CarFaultsApp());

    expect(find.byType(HomeSearchCard), findsOneWidget);
    expect(find.text('PESQUISAR VEÍCULO'), findsOneWidget);
  });

  testWidgets('tapping the avatar opens the LoginView', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CarFaultsApp());

    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.text('Entrar na conta'), findsOneWidget);
  });
}
