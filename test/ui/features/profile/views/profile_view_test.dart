import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/features/profile/views/profile_view.dart';
import 'package:car_faults_app/ui/features/profile/views/widgets/profile_account_info_card.dart';
import 'package:car_faults_app/ui/features/profile/views/widgets/profile_identity_card.dart';
import 'package:car_faults_app/ui/features/profile/views/widgets/profile_stats_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _app() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => LocaleViewModel(
          repository: LocaleRepository(service: LocalePreferencesService()),
        ),
      ),
      ChangeNotifierProvider(create: (_) => AuthSessionViewModel()),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ProfileView(),
    ),
  );
}

void main() {
  testWidgets('shows the identity card, the account card and the eyebrow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(find.text('CONTA'), findsOneWidget);
    expect(find.byType(ProfileIdentityCard), findsOneWidget);
    expect(find.byType(ProfileAccountInfoCard), findsOneWidget);
    expect(find.byType(ProfileStatsGrid), findsOneWidget);
    expect(
      find.text(
        'Dados obtidos de relatos públicos e entidades reguladoras. '
        'Não substitui uma avaliação técnica.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows the name once and the email in both cards', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(find.text('Ana Silva'), findsOneWidget);
    expect(find.text('ana@example.com'), findsNWidgets(2));
  });

  testWidgets('shows the four stats from the demo snapshot', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(find.text('47'), findsOneWidget);
    expect(find.text('128'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('23'), findsOneWidget);
  });
}
