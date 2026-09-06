import 'package:car_faults_app/data/repositories/activity_log_repository.dart';
import 'package:car_faults_app/data/repositories/auth_repository.dart';
import 'package:car_faults_app/data/repositories/community_repository.dart';
import 'package:car_faults_app/data/repositories/favorites_repository.dart';
import 'package:car_faults_app/data/repositories/garage_repository.dart';
import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/domain/models/user.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/features/login/views/login_view.dart';
import 'package:car_faults_app/ui/features/lookup/lookup_demo_display.dart';
import 'package:car_faults_app/ui/features/lookup/view_models/lookup_results_view_model.dart';
import 'package:car_faults_app/ui/features/lookup/views/lookup_results_view.dart';
import 'package:car_faults_app/ui/features/lookup/views/widgets/lookup_favorite_button.dart';
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
  @override
  Future<bool?> checkGarageStatus({
    required String vehicleModelId,
    required int year,
  }) async => null;
}

class _FakeActivityLogRepository extends ActivityLogRepository {
  @override
  Future<bool> recordDefectConsulted(String knownIssueId) async => true;
}

class _FakeFavoritesRepository extends FavoritesRepository {
  _FakeFavoritesRepository({this.statusResult = false, this.toggleResult});

  final bool statusResult;
  final bool? toggleResult;

  var checkFavoriteStatusCalls = 0;

  @override
  Future<bool> fetchStatus({
    required String vehicleModelId,
    required int year,
  }) async {
    checkFavoriteStatusCalls++;
    return statusResult;
  }

  @override
  Future<bool> favorite({
    required String vehicleModelId,
    required int year,
  }) async => toggleResult ?? true;

  @override
  Future<bool> unfavorite({
    required String vehicleModelId,
    required int year,
  }) async => toggleResult ?? true;
}

Widget _app({
  AuthSessionViewModel? session,
  FavoritesRepository? favoritesRepository,
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
          garageRepository: _FakeGarageRepository(),
          activityLogRepository: _FakeActivityLogRepository(),
          favoritesRepository:
              favoritesRepository ?? _FakeFavoritesRepository(),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows "Adicionar aos favoritos" when signed out', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Adicionar aos favoritos'), findsOneWidget);
  });

  testWidgets(
    'checks favorite status once when signed in and shows "Remover dos '
    'favoritos" if already favorited',
    (WidgetTester tester) async {
      final favoritesRepository = _FakeFavoritesRepository(statusResult: true);
      final session = AuthSessionViewModel()..setUser(_signedInUser);
      await tester.pumpWidget(
        _app(session: session, favoritesRepository: favoritesRepository),
      );
      await tester.pumpAndSettle();

      expect(favoritesRepository.checkFavoriteStatusCalls, 1);
      expect(find.text('Remover dos favoritos'), findsOneWidget);
    },
  );

  testWidgets('does not check favorite status when signed out', (
    WidgetTester tester,
  ) async {
    final favoritesRepository = _FakeFavoritesRepository();
    await tester.pumpWidget(_app(favoritesRepository: favoritesRepository));
    await tester.pumpAndSettle();

    expect(favoritesRepository.checkFavoriteStatusCalls, 0);
  });

  testWidgets('tapping the button while signed out asks to sign in first', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(LookupFavoriteButton));
    await tester.tap(find.byType(LookupFavoriteButton));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
  });

  testWidgets('tapping the button while signed in favorites the vehicle', (
    WidgetTester tester,
  ) async {
    final session = AuthSessionViewModel()..setUser(_signedInUser);
    await tester.pumpWidget(_app(session: session));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(LookupFavoriteButton));
    await tester.tap(find.byType(LookupFavoriteButton));
    await tester.pumpAndSettle();

    expect(find.text('Remover dos favoritos'), findsOneWidget);
  });

  testWidgets('tapping again unfavorites the vehicle', (
    WidgetTester tester,
  ) async {
    final session = AuthSessionViewModel()..setUser(_signedInUser);
    await tester.pumpWidget(_app(session: session));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(LookupFavoriteButton));
    await tester.tap(find.byType(LookupFavoriteButton));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(LookupFavoriteButton));
    await tester.tap(find.byType(LookupFavoriteButton));
    await tester.pumpAndSettle();

    expect(find.text('Adicionar aos favoritos'), findsOneWidget);
  });

  testWidgets('shows an error message on failure', (WidgetTester tester) async {
    final session = AuthSessionViewModel()..setUser(_signedInUser);
    final favoritesRepository = _FakeFavoritesRepository(toggleResult: false);
    await tester.pumpWidget(
      _app(session: session, favoritesRepository: favoritesRepository),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byType(LookupFavoriteButton));
    await tester.tap(find.byType(LookupFavoriteButton));
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível atualizar os favoritos. Tenta novamente.'),
      findsOneWidget,
    );
  });
}
