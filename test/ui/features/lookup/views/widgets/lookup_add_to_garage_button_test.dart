import 'package:car_faults_app/data/repositories/activity_log_repository.dart';
import 'package:car_faults_app/data/repositories/auth_repository.dart';
import 'package:car_faults_app/data/repositories/community_repository.dart';
import 'package:car_faults_app/data/repositories/garage_repository.dart';
import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/domain/models/saved_vehicle.dart';
import 'package:car_faults_app/domain/models/user.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/features/login/views/login_view.dart';
import 'package:car_faults_app/ui/features/lookup/lookup_demo_display.dart';
import 'package:car_faults_app/ui/features/lookup/view_models/lookup_results_view_model.dart';
import 'package:car_faults_app/ui/features/lookup/views/lookup_results_view.dart';
import 'package:car_faults_app/ui/features/lookup/views/widgets/lookup_add_to_garage_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const _signedInUser = User(
  id: 'u1',
  name: 'Daniel Fonseca',
  email: 'daniel@example.com',
);

/// Never reaches a real network: comments/reviews stay empty.
class _FakeCommunityRepository extends CommunityRepository {}

class _FakeGarageRepository extends GarageRepository {
  _FakeGarageRepository({this.statusResult, this.addResult});

  final bool? statusResult;
  final AddToGarageResult? addResult;

  var checkGarageStatusCalls = 0;

  @override
  Future<bool?> checkGarageStatus({
    required String vehicleModelId,
    required int year,
  }) async {
    checkGarageStatusCalls++;
    return statusResult;
  }

  @override
  Future<AddToGarageResult> addVehicle({
    required String vehicleModelId,
    required int year,
  }) async {
    return addResult ??
        AddToGarageSuccess(
          const SavedVehicle(
            id: 'uv-new',
            brand: 'VW',
            model: 'Polo',
            name: 'VW Polo',
            yearFrom: 2015,
            yearTo: 2015,
            knownIssuesCount: 0,
          ),
        );
  }
}

class _FakeActivityLogRepository extends ActivityLogRepository {
  @override
  Future<bool> recordDefectConsulted(String knownIssueId) async => true;
}

Widget _app({
  AuthSessionViewModel? session,
  GarageRepository? garageRepository,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => LocaleViewModel(
          repository: LocaleRepository(service: LocalePreferencesService()),
        ),
      ),
      ChangeNotifierProvider.value(value: session ?? AuthSessionViewModel()),
      Provider<AuthRepository>.value(value: AuthRepository()),
    ],
    child: MaterialApp(
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: LookupResultsView(
        viewModel: LookupResultsViewModel(
          vehicle: LookupDemoDisplay.vehicle,
          issues: LookupDemoDisplay.issues,
          repository: _FakeCommunityRepository(),
          garageRepository: garageRepository ?? _FakeGarageRepository(),
          activityLogRepository: _FakeActivityLogRepository(),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows "Adicionar à garagem" when signed out', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Adicionar à garagem'), findsOneWidget);
  });

  testWidgets(
    'checks garage status once when signed in and shows "Já está na tua '
    'garagem" if already owned',
    (WidgetTester tester) async {
      final garageRepository = _FakeGarageRepository(statusResult: true);
      final session = AuthSessionViewModel()..setUser(_signedInUser);
      await tester.pumpWidget(
        _app(session: session, garageRepository: garageRepository),
      );
      await tester.pumpAndSettle();

      expect(garageRepository.checkGarageStatusCalls, 1);
      expect(find.text('Já está na tua garagem'), findsOneWidget);

      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(button.onPressed, isNull);
    },
  );

  testWidgets('does not check garage status when signed out', (
    WidgetTester tester,
  ) async {
    final garageRepository = _FakeGarageRepository();
    await tester.pumpWidget(_app(garageRepository: garageRepository));
    await tester.pumpAndSettle();

    expect(garageRepository.checkGarageStatusCalls, 0);
  });

  testWidgets('tapping the button while signed out asks to sign in first', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(LookupAddToGarageButton));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
  });

  testWidgets('tapping the button while signed in adds the vehicle', (
    WidgetTester tester,
  ) async {
    final session = AuthSessionViewModel()..setUser(_signedInUser);
    await tester.pumpWidget(_app(session: session));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(LookupAddToGarageButton));
    await tester.pumpAndSettle();

    expect(find.text('Já está na tua garagem'), findsOneWidget);
  });

  testWidgets('shows an already-in-garage message on a duplicate result', (
    WidgetTester tester,
  ) async {
    final session = AuthSessionViewModel()..setUser(_signedInUser);
    final garageRepository = _FakeGarageRepository(
      addResult: const AddToGarageDuplicate(),
    );
    await tester.pumpWidget(
      _app(session: session, garageRepository: garageRepository),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(LookupAddToGarageButton));
    await tester.pumpAndSettle();

    expect(find.text('Este veículo já está na tua garagem.'), findsOneWidget);
  });

  testWidgets('shows an error message on failure', (WidgetTester tester) async {
    final session = AuthSessionViewModel()..setUser(_signedInUser);
    final garageRepository = _FakeGarageRepository(
      addResult: const AddToGarageFailure(),
    );
    await tester.pumpWidget(
      _app(session: session, garageRepository: garageRepository),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(LookupAddToGarageButton));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Não foi possível adicionar este veículo à garagem. Tenta '
        'novamente.',
      ),
      findsOneWidget,
    );
  });
}
