import 'package:car_faults_app/data/repositories/activity_log_repository.dart';
import 'package:car_faults_app/data/repositories/auth_repository.dart';
import 'package:car_faults_app/data/repositories/community_repository.dart';
import 'package:car_faults_app/data/repositories/garage_repository.dart';
import 'package:car_faults_app/data/repositories/locale_repository.dart';
import 'package:car_faults_app/data/services/locale_preferences_service.dart';
import 'package:car_faults_app/domain/models/comment.dart';
import 'package:car_faults_app/domain/models/issue_review.dart';
import 'package:car_faults_app/domain/models/report_reason.dart';
import 'package:car_faults_app/domain/models/user.dart';
import 'package:car_faults_app/l10n/app_localizations.dart';
import 'package:car_faults_app/ui/core/view_models/auth_session_view_model.dart';
import 'package:car_faults_app/ui/core/view_models/locale_view_model.dart';
import 'package:car_faults_app/ui/features/login/views/login_view.dart';
import 'package:car_faults_app/ui/features/lookup/lookup_demo_display.dart';
import 'package:car_faults_app/ui/features/lookup/view_models/lookup_results_view_model.dart';
import 'package:car_faults_app/ui/features/lookup/views/lookup_results_view.dart';
import 'package:car_faults_app/ui/features/lookup/views/widgets/lookup_issue_card.dart';
import 'package:car_faults_app/ui/features/lookup/views/widgets/lookup_star_rating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const _signedInUser = User(
  id: 'u1',
  name: 'Daniel Fonseca',
  email: 'daniel@example.com',
);

/// Never reaches a real network: [fetchReviews] returns `null`, leaving
/// whatever reviews the view model was seeded with (the demo data) in
/// place, and [submitReview] echoes back a review as the signed-in user.
class _FakeCommunityRepository extends CommunityRepository {
  @override
  Future<List<IssueReview>?> fetchReviews(String knownIssueId) async => null;

  @override
  Future<List<Comment>?> fetchComments(String knownIssueId) async => null;

  @override
  Future<SubmitReviewResult> submitReview({
    required String knownIssueId,
    required int rating,
    String? comment,
  }) async {
    return SubmitReviewSuccess(
      IssueReview(
        id: 'review-own',
        userId: _signedInUser.id,
        userName: _signedInUser.name,
        initials: 'DF',
        rating: rating,
        comment: comment ?? '',
        submittedAt: DateTime.now(),
      ),
    );
  }
}

/// Like [_FakeCommunityRepository], but also records [reportReview] calls.
class _FakeCommunityRepositoryTrackingReports extends _FakeCommunityRepository {
  SubmitReportResult reportResult = const SubmitReportSuccess();
  String? lastReportedReviewId;
  ReportReason? lastReportReason;

  @override
  Future<SubmitReportResult> reportReview({
    required String reviewId,
    required ReportReason reason,
    String? details,
  }) async {
    lastReportedReviewId = reviewId;
    lastReportReason = reason;
    return reportResult;
  }
}

/// Never reaches a real network: the add-to-garage button isn't exercised
/// by these tests.
class _FakeGarageRepository extends GarageRepository {
  @override
  Future<bool?> checkGarageStatus({
    required String vehicleModelId,
    required int year,
  }) async => null;
}

/// Never reaches a real network.
class _FakeActivityLogRepository extends ActivityLogRepository {
  @override
  Future<bool> recordDefectConsulted(String knownIssueId) async => true;
}

Widget _app({AuthSessionViewModel? session, CommunityRepository? repository}) {
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
          repository: repository ?? _FakeCommunityRepository(),
          garageRepository: _FakeGarageRepository(),
          activityLogRepository: _FakeActivityLogRepository(),
        ),
      ),
    ),
  );
}

Finder _card(String title) {
  return find.ancestor(
    of: find.text(title),
    matching: find.byType(LookupIssueCard),
  );
}

Finder _inCard(String title, Finder matching) {
  return find.descendant(of: _card(title), matching: matching);
}

/// The review form's submit button within [title]'s card — distinct from
/// the comment form's submit button.
Finder _submitButtonIn(String title) {
  return _inCard(
    title,
    find.widgetWithText(ElevatedButton, 'Submeter avaliação'),
  );
}

Future<void> _openIssue(WidgetTester tester, String title) async {
  final titleFinder = find.text(title);
  await tester.ensureVisible(titleFinder);
  await tester.pumpAndSettle();
  await tester.tap(titleFinder);
  await tester.pumpAndSettle();
}

void main() {
  const gearboxTitle = 'Caixa de câmbio problemática';
  const corrosionTitle = 'Corrosão na estrutura do assoalho';
  const emptyState =
      'Sem avaliações ainda. Sê o primeiro a classificar este defeito.';

  testWidgets(
    'the gearbox issue shows the 4.3 average and the 3 reviewer names',
    (WidgetTester tester) async {
      await tester.pumpWidget(_app());

      await _openIssue(tester, gearboxTitle);

      expect(_inCard(gearboxTitle, find.text('4.3')), findsOneWidget);
      expect(_inCard(gearboxTitle, find.text('3 avaliações')), findsOneWidget);
      expect(_inCard(gearboxTitle, find.text('Ricardo Moura')), findsOneWidget);
      expect(_inCard(gearboxTitle, find.text('Fábio Lopes')), findsOneWidget);
      expect(_inCard(gearboxTitle, find.text('Ana Silva')), findsOneWidget);
    },
  );

  testWidgets(
    'the corrosion issue shows the empty state and a form; submitting it '
    'while signed in reveals the "a tua avaliação" badge',
    (WidgetTester tester) async {
      final session = AuthSessionViewModel()..setUser(_signedInUser);
      await tester.pumpWidget(_app(session: session));

      await _openIssue(tester, corrosionTitle);

      expect(_inCard(corrosionTitle, find.text(emptyState)), findsOneWidget);
      expect(
        _inCard(corrosionTitle, find.text('a tua avaliação')),
        findsNothing,
      );
      expect(
        _inCard(corrosionTitle, find.text('Submeter avaliação')),
        findsOneWidget,
      );

      final submitButtonFinder = _submitButtonIn(corrosionTitle);
      final submitButton = tester.widget<ElevatedButton>(submitButtonFinder);
      expect(submitButton.onPressed, isNull);

      final fourthStar = _inCard(corrosionTitle, find.byType(IconButton)).at(3);
      await tester.ensureVisible(fourthStar);
      await tester.tap(fourthStar);
      await tester.pump();

      await tester.ensureVisible(submitButtonFinder);
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      expect(
        _inCard(corrosionTitle, find.text('a tua avaliação')),
        findsOneWidget,
      );
      expect(
        _inCard(corrosionTitle, find.byType(LookupStarRating)),
        findsWidgets,
      );
      expect(
        _inCard(corrosionTitle, find.text('Submeter avaliação')),
        findsNothing,
      );
    },
  );

  testWidgets('submitting a review while signed out asks to sign in first', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    await _openIssue(tester, corrosionTitle);

    final fourthStar = _inCard(corrosionTitle, find.byType(IconButton)).at(3);
    await tester.ensureVisible(fourthStar);
    await tester.tap(fourthStar);
    await tester.pump();

    final submitButtonFinder = _submitButtonIn(corrosionTitle);
    await tester.ensureVisible(submitButtonFinder);
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
  });

  testWidgets('reporting another user\'s review while signed in submits the report '
      'and shows a success message', (WidgetTester tester) async {
    final session = AuthSessionViewModel()..setUser(_signedInUser);
    final repository = _FakeCommunityRepositoryTrackingReports();
    await tester.pumpWidget(_app(session: session, repository: repository));

    await _openIssue(tester, gearboxTitle);

    final reportButtonFinder = _inCard(
      gearboxTitle,
      find.byIcon(Icons.flag_outlined),
    ).first;
    await tester.ensureVisible(reportButtonFinder);
    await tester.tap(reportButtonFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Spam'));
    await tester.pump();
    await tester.tap(find.text('Enviar denúncia'));
    await tester.pumpAndSettle();

    expect(repository.lastReportedReviewId, 'review-ricardo');
    expect(repository.lastReportReason, ReportReason.spam);
    expect(
      find.text(
        'Denúncia enviada. Obrigado por ajudares a manter a comunidade segura.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('reporting a review while signed out asks to sign in first', (
    WidgetTester tester,
  ) async {
    final repository = _FakeCommunityRepositoryTrackingReports();
    await tester.pumpWidget(_app(repository: repository));

    await _openIssue(tester, gearboxTitle);

    final reportButtonFinder = _inCard(
      gearboxTitle,
      find.byIcon(Icons.flag_outlined),
    ).first;
    await tester.ensureVisible(reportButtonFinder);
    await tester.tap(reportButtonFinder);
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(repository.lastReportedReviewId, isNull);
  });
}
