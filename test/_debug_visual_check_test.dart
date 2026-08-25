import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:car_faults_app/data/repositories/auth_repository.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/features/login/view_models/login_view_model.dart';
import 'package:car_faults_app/ui/features/login/views/login_view.dart';

void main() {
  testWidgets('debug: render LoginView to a PNG for manual visual check', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(780, 200);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LoginViewModel(authRepository: AuthRepository()),
        child: MaterialApp(
          theme: AppTheme.dark,
          locale: const Locale('pt'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LoginView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(LoginView),
      matchesGoldenFile('_debug_login_header.png'),
    );
  });
}
