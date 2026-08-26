import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/theme/app_colors.dart';
import 'package:car_faults_app/ui/features/home/views/widgets/home_hero_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpHero(WidgetTester tester) {
    return tester.pumpWidget(
      const MaterialApp(
        locale: Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: HomeHeroSection()),
      ),
    );
  }

  Text titleText(WidgetTester tester) {
    return tester.widget<Text>(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.textSpan != null,
      ),
    );
  }

  testWidgets('shows the eyebrow, the three title parts and the subtitle', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester);

    expect(find.text('BASE DE DADOS DE FIABILIDADE AUTOMÓVEL'), findsOneWidget);
    expect(find.textContaining('Pesquise avarias crónicas'), findsOneWidget);
    expect(
      titleText(tester).textSpan!.toPlainText(),
      'Conheça os defeitos antes de comprar',
    );
  });

  testWidgets('highlights defeitos in the primary color', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester);

    final span = titleText(tester).textSpan! as TextSpan;
    final highlight = span.children!.firstWhere(
      (child) => (child as TextSpan).text == 'defeitos',
    ) as TextSpan;

    expect(highlight.style?.color, AppColors.primary);
  });
}
