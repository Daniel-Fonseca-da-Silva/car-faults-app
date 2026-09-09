import 'dart:async';

import 'package:car_faults_app/data/repositories/auth_repository.dart';
import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/repositories/lookup_repository.dart';
import 'package:car_faults_app/data/repositories/profile_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/domain/models/app_locale.dart';
import 'package:car_faults_app/domain/models/lookup_vehicle.dart';
import 'package:car_faults_app/domain/models/profile_snapshot.dart';
import 'package:car_faults_app/domain/models/saved_vehicle.dart';
import 'package:car_faults_app/domain/models/user.dart';
import 'package:car_faults_app/domain/models/user_stats.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/theme/app_theme.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/features/home/home_search_options.dart';
import 'package:car_faults_app/ui/features/profile/view_models/profile_view_model.dart';
import 'package:car_faults_app/ui/features/profile/views/profile_view.dart';
import 'package:car_faults_app/ui/features/profile/views/widgets/profile_account_info_card.dart';
import 'package:car_faults_app/ui/features/profile/views/widgets/profile_danger_zone.dart';
import 'package:car_faults_app/ui/features/profile/views/widgets/profile_identity_card.dart';
import 'package:car_faults_app/ui/features/profile/views/widgets/profile_saved_vehicles_card.dart';
import 'package:car_faults_app/ui/features/profile/views/widgets/profile_stats_grid.dart';
import 'package:car_faults_app/ui/features/lookup/views/lookup_results_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const _vehicle = SavedVehicle(
  id: 'vw-polo',
  brand: 'Volkswagen',
  model: 'Polo',
  name: 'Polo 6N1',
  yearFrom: 1994,
  yearTo: 1999,
  knownIssuesCount: 3,
  engine: '1.4',
);

const _lookupVehicle = LookupVehicle(
  id: 'vm-1',
  brand: 'Volkswagen',
  model: 'Polo',
  name: 'Polo 6N1',
  yearFrom: 1994,
  yearTo: 1999,
  engine: '1.4',
  doors: 3,
  fuelType: 'gasoline',
  powerHp: 60,
);

final _snapshot = ProfileSnapshot(
  user: const User(id: 'u1', name: 'Ana Silva', email: 'ana@example.com'),
  createdAt: DateTime.utc(2026, 7, 17),
  updatedAt: DateTime.utc(2026, 7, 17),
  stats: const UserStats(
    searchesCount: 47,
    defectsConsultedCount: 128,
    savedVehiclesCount: 1,
    votesCount: 23,
    favoritedVehiclesCount: 9,
  ),
  vehicles: const [],
);

final _snapshotWithVehicle = ProfileSnapshot(
  user: _snapshot.user,
  createdAt: _snapshot.createdAt,
  updatedAt: _snapshot.updatedAt,
  stats: _snapshot.stats,
  vehicles: const [_vehicle],
);

class _FakeProfileRepository extends ProfileRepository {
  _FakeProfileRepository({this.snapshot});

  ProfileSnapshot? snapshot;

  @override
  Future<ProfileSnapshot?> fetchSnapshot({required AppLocale locale}) async =>
      snapshot;
}

class _SuccessAuthRepository extends AuthRepository {
  @override
  Future<DeleteAccountResult> deleteAccount() async =>
      const DeleteAccountSuccess();
}

class _DelayedProfileRepository extends ProfileRepository {
  final completer = Completer<ProfileSnapshot?>();

  @override
  Future<ProfileSnapshot?> fetchSnapshot({required AppLocale locale}) =>
      completer.future;
}

class _FailureAuthRepository extends AuthRepository {
  @override
  Future<DeleteAccountResult> deleteAccount() async =>
      const DeleteAccountFailure();
}

class _FakeLookupRepository extends LookupRepository {
  _FakeLookupRepository({this.result});

  LookupSearchResult? result;

  @override
  Future<LookupSearchResult> search({
    required String brand,
    required String model,
    required int year,
    required String engine,
    required FuelOption fuel,
    int? doors,
    required AppLocale locale,
  }) async {
    return result ??
        const LookupSearchSuccess(vehicle: _lookupVehicle, issues: []);
  }
}

Widget _app({
  ProfileRepository? repository,
  AuthRepository? authRepository,
  LookupRepository? lookupRepository,
  AuthSessionViewModel? session,
  GlobalKey<NavigatorState>? navigatorKey,
  Widget home = const ProfileView(),
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => LocaleViewModel(
          repository: LocaleRepository(service: LocalePreferencesService()),
        ),
      ),
      ChangeNotifierProvider.value(value: session ?? AuthSessionViewModel()),
      ChangeNotifierProvider(
        create: (_) => ProfileViewModel(
          authRepository: authRepository ?? _SuccessAuthRepository(),
          repository: repository ?? _FakeProfileRepository(),
          lookupRepository: lookupRepository ?? _FakeLookupRepository(),
          locale: AppLocale.pt,
        )..load(),
      ),
    ],
    child: MaterialApp(
      navigatorKey: navigatorKey,
      theme: AppTheme.dark,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

void main() {
  testWidgets('shows a loading indicator while the snapshot loads', (
    WidgetTester tester,
  ) async {
    final repository = _DelayedProfileRepository();
    await tester.pumpWidget(_app(repository: repository));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    repository.completer.complete(_snapshot);
    await tester.pumpAndSettle();
  });

  testWidgets('shows the identity card, the account card and the eyebrow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(repository: _FakeProfileRepository(snapshot: _snapshot)),
    );
    await tester.pumpAndSettle();

    expect(find.text('CONTA'), findsOneWidget);
    expect(find.byType(ProfileIdentityCard), findsOneWidget);
    expect(find.byType(ProfileAccountInfoCard), findsOneWidget);
    expect(find.byType(ProfileStatsGrid), findsOneWidget);
    expect(find.byType(ProfileSavedVehiclesCard), findsOneWidget);
    expect(find.byType(ProfileDangerZone), findsOneWidget);
  });

  testWidgets('shows the name once and the email in both cards', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(repository: _FakeProfileRepository(snapshot: _snapshot)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ana Silva'), findsOneWidget);
    expect(find.text('ana@example.com'), findsNWidgets(2));
  });

  testWidgets('shows the four stats from the loaded snapshot', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(repository: _FakeProfileRepository(snapshot: _snapshot)),
    );
    await tester.pumpAndSettle();

    expect(find.text('47'), findsOneWidget);
    expect(find.text('128'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('23'), findsOneWidget);
  });

  testWidgets('shows an error state with a retry button when loading fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(repository: _FakeProfileRepository()));
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível carregar o seu perfil.'),
      findsOneWidget,
    );
    expect(find.byType(ProfileIdentityCard), findsNothing);
  });

  testWidgets('tapping retry reloads the snapshot', (
    WidgetTester tester,
  ) async {
    final repository = _FakeProfileRepository();
    await tester.pumpWidget(_app(repository: repository));
    await tester.pumpAndSettle();

    repository.snapshot = _snapshot;
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileIdentityCard), findsOneWidget);
  });

  testWidgets('confirming account deletion signs out and pops the screen', (
    WidgetTester tester,
  ) async {
    final session = AuthSessionViewModel()
      ..setUser(
        const User(id: 'u1', name: 'Ana Silva', email: 'ana@example.com'),
      );
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      _app(
        repository: _FakeProfileRepository(snapshot: _snapshot),
        authRepository: _SuccessAuthRepository(),
        session: session,
        navigatorKey: navigatorKey,
        home: const Scaffold(body: Text('home')),
      ),
    );
    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const ProfileView()),
    );
    await tester.pumpAndSettle();

    final deleteButton = find.text('Excluir conta').last;
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sim, excluir conta'));
    await tester.pumpAndSettle();

    expect(session.isSignedIn, isFalse);
    expect(find.byType(ProfileView), findsNothing);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('a failed deletion shows an error SnackBar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        repository: _FakeProfileRepository(snapshot: _snapshot),
        authRepository: _FailureAuthRepository(),
      ),
    );
    await tester.pumpAndSettle();

    final deleteButton = find.text('Excluir conta').last;
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sim, excluir conta'));
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível excluir a sua conta. Tente novamente.'),
      findsOneWidget,
    );
  });

  testWidgets('tapping a saved vehicle opens its real lookup results', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(repository: _FakeProfileRepository(snapshot: _snapshotWithVehicle)),
    );
    await tester.pumpAndSettle();

    final vehicleRow = find.text('Volkswagen Polo 6N1');
    await tester.ensureVisible(vehicleRow);
    await tester.tap(vehicleRow);
    await tester.pumpAndSettle();

    expect(find.byType(LookupResultsView), findsOneWidget);
  });

  testWidgets('a failed vehicle lookup shows an error SnackBar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        repository: _FakeProfileRepository(snapshot: _snapshotWithVehicle),
        lookupRepository: _FakeLookupRepository(
          result: const LookupSearchFailure(LookupFailureReason.notFound),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final vehicleRow = find.text('Volkswagen Polo 6N1');
    await tester.ensureVisible(vehicleRow);
    await tester.tap(vehicleRow);
    await tester.pumpAndSettle();

    expect(find.text('Veículo não encontrado.'), findsOneWidget);
  });
}
