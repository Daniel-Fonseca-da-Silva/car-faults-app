import 'package:car_faults_app/data/repositories/community_repository.dart';
import 'package:car_faults_app/domain/models/fix_vote_value.dart';
import 'package:car_faults_app/domain/models/issue_fix.dart';
import 'package:car_faults_app/domain/models/issue_review.dart';
import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:car_faults_app/domain/models/known_issue.dart';
import 'package:car_faults_app/ui/features/lookup/lookup_demo_display.dart';
import 'package:car_faults_app/ui/features/lookup/view_models/lookup_results_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCommunityRepository extends CommunityRepository {
  _FakeCommunityRepository({
    this.reviewsById = const {},
    this.submitResult,
    this.voteResult,
    this.removeVoteResult = true,
  });

  final Map<String, List<IssueReview>?> reviewsById;
  final SubmitReviewResult? submitResult;
  final IssueFix? voteResult;
  final bool removeVoteResult;

  var fetchReviewsCalls = <String>[];
  var voteFixCalls = <(String, FixVoteValue)>[];
  var removeFixVoteCalls = <String>[];

  @override
  Future<List<IssueReview>?> fetchReviews(String knownIssueId) async {
    fetchReviewsCalls.add(knownIssueId);
    if (!reviewsById.containsKey(knownIssueId)) return const [];
    return reviewsById[knownIssueId];
  }

  @override
  Future<SubmitReviewResult> submitReview({
    required String knownIssueId,
    required int rating,
    String? comment,
  }) async {
    return submitResult ??
        SubmitReviewSuccess(
          IssueReview(
            id: 'review-new',
            userId: 'user-1',
            userName: 'New User',
            initials: 'NU',
            rating: rating,
            comment: comment ?? '',
            submittedAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<IssueFix?> voteFix(String fixId, FixVoteValue value) async {
    voteFixCalls.add((fixId, value));
    return voteResult;
  }

  @override
  Future<bool> removeFixVote(String fixId) async {
    removeFixVoteCalls.add(fixId);
    return removeVoteResult;
  }
}

const _issue = KnownIssue(
  id: 'issue-1',
  title: 'Timing belt wear',
  description: 'Wears out early.',
  severity: IssueSeverity.high,
  sources: [],
  fixes: [
    IssueFix(
      id: 'fix-1',
      summary: 'Replace belt',
      steps: ['Step one'],
      estimatedCostEur: 100,
      likes: 5,
      dislikes: 1,
    ),
  ],
  reviews: [],
);

LookupResultsViewModel _viewModel({CommunityRepository? repository}) {
  return LookupResultsViewModel(
    issues: const [_issue],
    repository: repository ?? _FakeCommunityRepository(),
  );
}

void main() {
  test('toggleIssue expands and collapses an issue', () async {
    final viewModel = _viewModel();

    expect(viewModel.isIssueExpanded('issue-1'), isFalse);

    viewModel.toggleIssue('issue-1');
    expect(viewModel.isIssueExpanded('issue-1'), isTrue);

    viewModel.toggleIssue('issue-1');
    expect(viewModel.isIssueExpanded('issue-1'), isFalse);
  });

  test('toggleIssue fetches reviews once from the repository and caches '
      'them', () async {
    final repository = _FakeCommunityRepository(
      reviewsById: {
        'issue-1': [
          IssueReview(
            id: 'review-1',
            userId: 'user-1',
            userName: 'Ada',
            initials: 'A',
            rating: 5,
            comment: 'Great info',
            submittedAt: DateTime.now(),
          ),
        ],
      },
    );
    final viewModel = _viewModel(repository: repository);

    viewModel.toggleIssue('issue-1');
    expect(viewModel.isLoadingReviews('issue-1'), isTrue);
    await Future<void>.value();
    await Future<void>.value();

    expect(viewModel.isLoadingReviews('issue-1'), isFalse);
    expect(viewModel.reviewsFor('issue-1'), hasLength(1));
    expect(viewModel.reviewsFor('issue-1').single.userName, 'Ada');

    viewModel.toggleIssue('issue-1');
    viewModel.toggleIssue('issue-1');
    await Future<void>.value();

    expect(repository.fetchReviewsCalls, ['issue-1']);
  });

  test(
    'toggleIssue leaves seeded reviews in place when the fetch fails',
    () async {
      final repository = _FakeCommunityRepository(
        reviewsById: {'issue-1': null},
      );
      final viewModel = LookupResultsViewModel(
        issues: [
          KnownIssue(
            id: 'issue-1',
            title: _issue.title,
            description: _issue.description,
            severity: _issue.severity,
            sources: _issue.sources,
            fixes: _issue.fixes,
            reviews: [
              IssueReview(
                id: 'seeded',
                userId: 'user-seed',
                userName: 'Seed',
                initials: 'S',
                rating: 3,
                comment: '',
                submittedAt: DateTime.now(),
              ),
            ],
          ),
        ],
        repository: repository,
      );

      viewModel.toggleIssue('issue-1');
      await Future<void>.value();
      await Future<void>.value();

      expect(viewModel.reviewsFor('issue-1'), hasLength(1));
      expect(viewModel.reviewsFor('issue-1').single.id, 'seeded');
    },
  );

  test('averageFor returns null when an issue has no reviews', () {
    final viewModel = _viewModel();

    expect(viewModel.averageFor('issue-1'), isNull);
  });

  test('averageFor returns the mean rating of the loaded reviews', () async {
    final repository = _FakeCommunityRepository(
      reviewsById: {
        'issue-1': [
          IssueReview(
            id: 'r1',
            userId: 'u1',
            userName: 'A',
            initials: 'A',
            rating: 5,
            comment: '',
            submittedAt: DateTime.now(),
          ),
          IssueReview(
            id: 'r2',
            userId: 'u2',
            userName: 'B',
            initials: 'B',
            rating: 3,
            comment: '',
            submittedAt: DateTime.now(),
          ),
        ],
      },
    );
    final viewModel = _viewModel(repository: repository);

    viewModel.toggleIssue('issue-1');
    await Future<void>.value();
    await Future<void>.value();

    expect(viewModel.averageFor('issue-1'), 4.0);
  });

  test('hasOwnReview is false when signed out', () async {
    final viewModel = _viewModel();

    expect(viewModel.hasOwnReview('issue-1', null), isFalse);
  });

  test('hasOwnReview is true once the signed-in user has a review', () async {
    final repository = _FakeCommunityRepository(
      reviewsById: {
        'issue-1': [
          IssueReview(
            id: 'r1',
            userId: 'user-1',
            userName: 'Ada',
            initials: 'A',
            rating: 5,
            comment: '',
            submittedAt: DateTime.now(),
          ),
        ],
      },
    );
    final viewModel = _viewModel(repository: repository);

    viewModel.toggleIssue('issue-1');
    await Future<void>.value();
    await Future<void>.value();

    expect(viewModel.hasOwnReview('issue-1', 'user-1'), isTrue);
    expect(viewModel.hasOwnReview('issue-1', 'user-2'), isFalse);
  });

  test('submitReview appends the new review and notifies listeners', () async {
    final viewModel = _viewModel();
    var notified = false;
    viewModel.addListener(() => notified = true);

    final result = await viewModel.submitReview(
      issueId: 'issue-1',
      rating: 4,
      comment: 'Confirmed on my car.',
    );

    expect(result, isA<SubmitReviewSuccess>());
    expect(notified, isTrue);
    expect(viewModel.reviewsFor('issue-1'), hasLength(1));
    expect(viewModel.reviewsFor('issue-1').single.rating, 4);
  });

  test(
    'submitReview surfaces a duplicate result without adding a review',
    () async {
      final repository = _FakeCommunityRepository(
        submitResult: const SubmitReviewDuplicate(),
      );
      final viewModel = _viewModel(repository: repository);

      final result = await viewModel.submitReview(
        issueId: 'issue-1',
        rating: 1,
      );

      expect(result, isA<SubmitReviewDuplicate>());
      expect(viewModel.reviewsFor('issue-1'), isEmpty);
    },
  );

  test(
    'submitReview surfaces a failure result without adding a review',
    () async {
      final repository = _FakeCommunityRepository(
        submitResult: const SubmitReviewFailure(),
      );
      final viewModel = _viewModel(repository: repository);

      final result = await viewModel.submitReview(
        issueId: 'issue-1',
        rating: 1,
      );

      expect(result, isA<SubmitReviewFailure>());
      expect(viewModel.reviewsFor('issue-1'), isEmpty);
    },
  );

  test('isFixExpanded toggles independently of issue expansion', () {
    final viewModel = _viewModel();

    expect(viewModel.isFixExpanded('fix-1'), isFalse);
    viewModel.toggleFixSteps('fix-1');
    expect(viewModel.isFixExpanded('fix-1'), isTrue);
  });

  test('likesFor and dislikesFor read the seeded fix counts', () {
    final viewModel = _viewModel();

    expect(viewModel.likesFor('fix-1'), 5);
    expect(viewModel.dislikesFor('fix-1'), 1);
    expect(viewModel.myVoteFor('fix-1'), isNull);
  });

  test('voteLike calls the repository and applies the returned fix', () async {
    final repository = _FakeCommunityRepository(
      voteResult: const IssueFix(
        id: 'fix-1',
        summary: 'Replace belt',
        steps: ['Step one'],
        estimatedCostEur: 100,
        likes: 6,
        dislikes: 1,
        myVote: FixVoteValue.like,
      ),
    );
    final viewModel = _viewModel(repository: repository);

    await viewModel.voteLike('fix-1');

    expect(repository.voteFixCalls, [('fix-1', FixVoteValue.like)]);
    expect(viewModel.likesFor('fix-1'), 6);
    expect(viewModel.myVoteFor('fix-1'), FixVoteValue.like);
  });

  test('voteLike again removes the vote via the repository', () async {
    final repository = _FakeCommunityRepository(
      voteResult: const IssueFix(
        id: 'fix-1',
        summary: 'Replace belt',
        steps: ['Step one'],
        estimatedCostEur: 100,
        likes: 6,
        dislikes: 1,
        myVote: FixVoteValue.like,
      ),
    );
    final viewModel = _viewModel(repository: repository);

    await viewModel.voteLike('fix-1');
    await viewModel.voteLike('fix-1');

    expect(repository.removeFixVoteCalls, ['fix-1']);
    expect(viewModel.likesFor('fix-1'), 5);
    expect(viewModel.myVoteFor('fix-1'), isNull);
  });

  test(
    'voteDislike does not change state when the repository call fails',
    () async {
      final repository = _FakeCommunityRepository(voteResult: null);
      final viewModel = _viewModel(repository: repository);

      await viewModel.voteDislike('fix-1');

      expect(viewModel.dislikesFor('fix-1'), 1);
      expect(viewModel.myVoteFor('fix-1'), isNull);
    },
  );

  test('voteLike again keeps the previous vote when removal fails', () async {
    final repository = _FakeCommunityRepository(
      voteResult: const IssueFix(
        id: 'fix-1',
        summary: 'Replace belt',
        steps: ['Step one'],
        estimatedCostEur: 100,
        likes: 6,
        dislikes: 1,
        myVote: FixVoteValue.like,
      ),
      removeVoteResult: false,
    );
    final viewModel = _viewModel(repository: repository);

    await viewModel.voteLike('fix-1');
    await viewModel.voteLike('fix-1');

    expect(viewModel.likesFor('fix-1'), 6);
    expect(viewModel.myVoteFor('fix-1'), FixVoteValue.like);
  });

  test('falls back to LookupDemoDisplay data when nothing is passed in', () {
    final viewModel = LookupResultsViewModel(
      repository: _FakeCommunityRepository(),
    );

    expect(viewModel.vehicle.id, LookupDemoDisplay.vehicle.id);
    expect(viewModel.issues, hasLength(LookupDemoDisplay.issues.length));
  });
}
