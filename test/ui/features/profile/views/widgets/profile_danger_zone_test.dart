import 'package:car_faults_app/data/repositories/auth_repository.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/features/profile/view_models/profile_view_model.dart';
import 'package:car_faults_app/ui/features/profile/views/widgets/profile_danger_zone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Resolves [deleteAccount] immediately without a real network call, so
/// [ProfileDangerZone]'s confirmation-dialog flow can be tested in
/// isolation.
class _FakeAuthRepository extends AuthRepository {
  @override
  Future<DeleteAccountResult> deleteAccount() async =>
      const DeleteAccountSuccess();
}

Widget _app(ProfileViewModel viewModel) {
  return MaterialApp(
    theme: AppTheme.dark,
    locale: const Locale('pt'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: ProfileDangerZone(viewModel: viewModel)),
  );
}

void main() {
  testWidgets('shows the danger-zone title, description and button', (
    WidgetTester tester,
  ) async {
    final viewModel = ProfileViewModel(authRepository: _FakeAuthRepository());
    await tester.pumpWidget(_app(viewModel));

    expect(find.text('ZONA DE RISCO'), findsOneWidget);
    expect(find.text('Excluir conta'), findsNWidgets(2));
    expect(
      find.text(
        'Apaga permanentemente todos os seus dados. '
        'Esta acção não pode ser desfeita.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('tapping the button opens the confirmation dialog', (
    WidgetTester tester,
  ) async {
    final viewModel = ProfileViewModel(authRepository: _FakeAuthRepository());
    await tester.pumpWidget(_app(viewModel));

    await tester.tap(find.text('Excluir conta').last);
    await tester.pumpAndSettle();

    expect(find.text('Tem a certeza?'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('Cancelar closes the dialog without calling the repository', (
    WidgetTester tester,
  ) async {
    final viewModel = ProfileViewModel(authRepository: _FakeAuthRepository());
    await tester.pumpWidget(_app(viewModel));

    await tester.tap(find.text('Excluir conta').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(viewModel.lastResult, isNull);
  });

  testWidgets('confirming calls deleteAccount and resolves to success', (
    WidgetTester tester,
  ) async {
    final viewModel = ProfileViewModel(authRepository: _FakeAuthRepository());
    await tester.pumpWidget(_app(viewModel));

    await tester.tap(find.text('Excluir conta').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sim, excluir conta'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(viewModel.lastResult, const DeleteAccountSuccess());
  });
}
