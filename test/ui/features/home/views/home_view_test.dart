import 'package:car_faults_app/main.dart';
import 'package:car_faults_app/ui/core/widgets/app_footer.dart';
import 'package:car_faults_app/ui/core/widgets/app_header.dart';
import 'package:car_faults_app/ui/core/widgets/app_menu_button.dart';
import 'package:car_faults_app/ui/core/widgets/brand_wordmark.dart';
import 'package:car_faults_app/ui/features/home/views/widgets/home_search_card.dart';
import 'package:car_faults_app/ui/features/login/views/login_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HomeView shows AppHeader and AppFooter', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(CarFaultsApp());

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
    await tester.pumpWidget(CarFaultsApp());

    expect(find.byType(HomeSearchCard), findsOneWidget);
    expect(find.text('PESQUISAR VEÍCULO'), findsOneWidget);
  });

  testWidgets('opening the menu and tapping Entrar opens the LoginView', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(CarFaultsApp());

    await tester.tap(find.byType(AppMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.text('Entrar na conta'), findsOneWidget);
  });
}
