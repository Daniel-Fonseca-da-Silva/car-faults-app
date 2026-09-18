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
import 'package:car_faults_app/ui/features/lookup/views/widgets/lookup_comment_item.dart';
import 'package:car_faults_app/ui/features/lookup/views/widgets/lookup_issue_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const _signedInUser = User(
  id: 'u1',
  name: 'Daniel Fonseca',
  email: 'daniel@example.com',
);

/// Never reaches a real network: [fetchReviews]/[fetchComments] return
/// `null` (stay empty) and [submitComment] echoes back a comment as the
/// signed-in user.
class _FakeCommunityRepository extends CommunityRepository {
  @override
  Future<List<IssueReview>?> fetchReviews(String knownIssueId) async => null;

  @override
  Future<List<Comment>?> fetchComments(String knownIssueId) async => null;

  @override
  Future<SubmitCommentResult> submitComment({
    required String knownIssueId,
    required String body,
    String? imageUrl,
  }) async {
    return SubmitCommentSuccess(
      Comment(
        id: 'comment-own',
        userId: _signedInUser.id,
        userName: _signedInUser.name,
        initials: 'DF',
        body: body,
        imageUrl: imageUrl,
        submittedAt: DateTime.now(),
      ),
    );
  }
}

/// Seeds one comment from a different user (so its report action is
/// enabled) and records [reportComment] calls.
class _FakeCommunityRepositoryWithOthersComment extends CommunityRepository {
  final SubmitReportResult reportResult = const SubmitReportSuccess();
  String? lastReportedCommentId;
  ReportReason? lastReportReason;
  String? lastReportDetails;

  @override
  Future<List<IssueReview>?> fetchReviews(String knownIssueId) async => null;

  @override
  Future<List<Comment>?> fetchComments(String knownIssueId) async => [
    Comment(
      id: 'comment-other',
      userId: 'other-user',
      userName: 'Ana Silva',
      initials: 'AS',
      body: 'O comentário de outra pessoa.',
      imageUrl: null,
      submittedAt: DateTime.now(),
    ),
  ];

  @override
  Future<SubmitReportResult> reportComment({
    required String commentId,
    required ReportReason reason,
    String? details,
  }) async {
    lastReportedCommentId = commentId;
    lastReportReason = reason;
    lastReportDetails = details;
    return reportResult;
  }
}

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

Future<void> _openIssue(WidgetTester tester, String title) async {
  final titleFinder = find.text(title);
  await tester.ensureVisible(titleFinder);
  await tester.pumpAndSettle();
  await tester.tap(titleFinder);
  await tester.pumpAndSettle();
}

/// The comment body field within [title]'s card — distinct from the review
/// form's comment field rendered in the same expanded card.
Finder _bodyFieldIn(String title) {
  return _inCard(
    title,
    find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText ==
              'Partilha a tua experiência com este defeito',
    ),
  );
}

/// The comment form's submit button within [title]'s card — distinct from
/// the review form's submit button.
Finder _submitButtonIn(String title) {
  return _inCard(
    title,
    find.widgetWithText(ElevatedButton, 'Publicar comentário'),
  );
}

/// The report ("flag") buttons on comment items within [title]'s card —
/// distinct from the ones review items also render since reviews and
/// comments share the same icon.
Finder _commentReportButtonsIn(String title) {
  return find.descendant(
    of: _inCard(title, find.byType(LookupCommentItem)),
    matching: find.byIcon(Icons.flag_outlined),
  );
}

void main() {
  const gearboxTitle = 'Caixa de câmbio problemática';
  const emptyState =
      'Ainda não há comentários. Sê o primeiro a partilhar a tua experiência.';

  testWidgets(
    'shows the empty state and a comment form; submitting it while signed '
    'in reveals the "o teu comentário" badge',
    (WidgetTester tester) async {
      final session = AuthSessionViewModel()..setUser(_signedInUser);
      await tester.pumpWidget(_app(session: session));

      await _openIssue(tester, gearboxTitle);

      expect(_inCard(gearboxTitle, find.text(emptyState)), findsOneWidget);
      expect(
        _inCard(gearboxTitle, find.text('o teu comentário')),
        findsNothing,
      );

      final bodyFieldFinder = _bodyFieldIn(gearboxTitle);
      await tester.ensureVisible(bodyFieldFinder);
      await tester.enterText(bodyFieldFinder, 'Confirmo, aconteceu-me também.');
      await tester.pump();

      final submitButtonFinder = _submitButtonIn(gearboxTitle);
      await tester.ensureVisible(submitButtonFinder);
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      expect(
        _inCard(gearboxTitle, find.text('o teu comentário')),
        findsOneWidget,
      );
      expect(
        _inCard(gearboxTitle, find.text('Confirmo, aconteceu-me também.')),
        findsOneWidget,
      );
    },
  );

  testWidgets('the submit button stays disabled with an empty body', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    await _openIssue(tester, gearboxTitle);

    final submitButtonFinder = _submitButtonIn(gearboxTitle);
    final submitButton = tester.widget<ElevatedButton>(submitButtonFinder);
    expect(submitButton.onPressed, isNull);
  });

  testWidgets('submitting a comment while signed out asks to sign in first', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    await _openIssue(tester, gearboxTitle);

    final bodyFieldFinder = _bodyFieldIn(gearboxTitle);
    await tester.ensureVisible(bodyFieldFinder);
    await tester.enterText(bodyFieldFinder, 'Confirmo, aconteceu-me também.');
    await tester.pump();

    final submitButtonFinder = _submitButtonIn(gearboxTitle);
    await tester.ensureVisible(submitButtonFinder);
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
  });

  testWidgets('reporting another user\'s comment while signed in submits the report '
      'and shows a success message', (WidgetTester tester) async {
    final session = AuthSessionViewModel()..setUser(_signedInUser);
    final repository = _FakeCommunityRepositoryWithOthersComment();
    await tester.pumpWidget(_app(session: session, repository: repository));

    await _openIssue(tester, gearboxTitle);

    final reportButtonFinder = _commentReportButtonsIn(gearboxTitle);
    await tester.ensureVisible(reportButtonFinder);
    await tester.tap(reportButtonFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Spam'));
    await tester.pump();
    await tester.tap(find.text('Enviar denúncia'));
    await tester.pumpAndSettle();

    expect(repository.lastReportedCommentId, 'comment-other');
    expect(repository.lastReportReason, ReportReason.spam);
    expect(
      find.text(
        'Denúncia enviada. Obrigado por ajudares a manter a comunidade segura.',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'the report action is hidden on the signed-in user\'s own comment',
    (WidgetTester tester) async {
      final session = AuthSessionViewModel()..setUser(_signedInUser);
      await tester.pumpWidget(_app(session: session));

      await _openIssue(tester, gearboxTitle);

      final bodyFieldFinder = _bodyFieldIn(gearboxTitle);
      await tester.ensureVisible(bodyFieldFinder);
      await tester.enterText(bodyFieldFinder, 'Confirmo, aconteceu-me também.');
      await tester.pump();

      final submitButtonFinder = _submitButtonIn(gearboxTitle);
      await tester.ensureVisible(submitButtonFinder);
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      expect(_commentReportButtonsIn(gearboxTitle), findsNothing);
    },
  );
}
