import 'package:car_faults_app/data/repositories/community_repository.dart';
import 'package:car_faults_app/data/services/fixes_api_service.dart';
import 'package:car_faults_app/data/services/reviews_api_service.dart';
import 'package:car_faults_app/domain/models/fix_vote_value.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeReviewsApiService extends ReviewsApiService {
  _FakeReviewsApiService({this.listResponse, this.createResponse, this.error})
    : super(dio: Dio());

  final Map<String, dynamic>? listResponse;
  final Map<String, dynamic>? createResponse;
  final DioException? error;

  String? lastKnownIssueId;
  int? lastRating;
  String? lastComment;

  @override
  Future<Map<String, dynamic>> list({required String knownIssueId}) async {
    lastKnownIssueId = knownIssueId;
    if (error != null) throw error!;
    return listResponse!;
  }

  @override
  Future<Map<String, dynamic>> create({
    required String knownIssueId,
    required int rating,
    String? comment,
  }) async {
    lastKnownIssueId = knownIssueId;
    lastRating = rating;
    lastComment = comment;
    if (error != null) throw error!;
    return createResponse!;
  }
}

class _FakeFixesApiService extends FixesApiService {
  _FakeFixesApiService({this.voteResponse, this.error}) : super(dio: Dio());

  final Map<String, dynamic>? voteResponse;
  final DioException? error;

  String? lastFixId;
  String? lastValue;
  var removeVoteCalls = 0;

  @override
  Future<Map<String, dynamic>> vote({
    required String fixId,
    required String value,
  }) async {
    lastFixId = fixId;
    lastValue = value;
    if (error != null) throw error!;
    return voteResponse!;
  }

  @override
  Future<void> removeVote({required String fixId}) async {
    lastFixId = fixId;
    removeVoteCalls++;
    if (error != null) throw error!;
  }
}

DioException _dioError({int? statusCode}) {
  final requestOptions = RequestOptions(path: '/v1/reviews');
  return DioException(
    requestOptions: requestOptions,
    response: statusCode == null
        ? null
        : Response<dynamic>(
            requestOptions: requestOptions,
            statusCode: statusCode,
          ),
    type: statusCode == null
        ? DioExceptionType.connectionError
        : DioExceptionType.badResponse,
  );
}

const _reviewJson = {
  'id': 'review-1',
  'userId': 'user-1',
  'knownIssueId': 'issue-1',
  'rating': 4,
  'comment': 'Fixed it myself',
  'userName': 'Ada Lovelace',
  'createdAt': '2026-07-17T10:00:00.000Z',
  'updatedAt': '2026-07-17T10:00:00.000Z',
};

const _fixJson = {
  'id': 'fix-1',
  'knownIssueId': 'issue-1',
  'userId': 'user-2',
  'summary': 'Replace gearbox synchros',
  'steps': 'Step one\nStep two',
  'estimatedCostEur': '450.00',
  'source': 'user',
  'likes': 13,
  'dislikes': 2,
  'myVote': 'like',
  'createdAt': '2026-07-17T10:00:00.000Z',
  'updatedAt': '2026-07-17T10:00:00.000Z',
};

void main() {
  group('fetchReviews', () {
    test('maps a successful page response', () async {
      final repository = CommunityRepository(
        reviewsApiService: _FakeReviewsApiService(
          listResponse: {
            'items': [_reviewJson],
            'nextCursor': null,
          },
        ),
      );

      final reviews = await repository.fetchReviews('issue-1');

      expect(reviews, hasLength(1));
      expect(reviews!.single.id, 'review-1');
      expect(reviews.single.userName, 'Ada Lovelace');
    });

    test('returns null on a DioException', () async {
      final repository = CommunityRepository(
        reviewsApiService: _FakeReviewsApiService(error: _dioError()),
      );

      expect(await repository.fetchReviews('issue-1'), isNull);
    });
  });

  group('submitReview', () {
    test('returns SubmitReviewSuccess with the mapped review', () async {
      final api = _FakeReviewsApiService(createResponse: _reviewJson);
      final repository = CommunityRepository(reviewsApiService: api);

      final result = await repository.submitReview(
        knownIssueId: 'issue-1',
        rating: 4,
        comment: 'Fixed it myself',
      );

      expect(api.lastKnownIssueId, 'issue-1');
      expect(api.lastRating, 4);
      expect(result, isA<SubmitReviewSuccess>());
      expect((result as SubmitReviewSuccess).review.id, 'review-1');
    });

    test('maps a 409 response to SubmitReviewDuplicate', () async {
      final repository = CommunityRepository(
        reviewsApiService: _FakeReviewsApiService(
          error: _dioError(statusCode: 409),
        ),
      );

      final result = await repository.submitReview(
        knownIssueId: 'issue-1',
        rating: 1,
      );

      expect(result, isA<SubmitReviewDuplicate>());
    });

    test('maps other errors to SubmitReviewFailure', () async {
      final repository = CommunityRepository(
        reviewsApiService: _FakeReviewsApiService(
          error: _dioError(statusCode: 500),
        ),
      );

      final result = await repository.submitReview(
        knownIssueId: 'issue-1',
        rating: 1,
      );

      expect(result, isA<SubmitReviewFailure>());
    });
  });

  group('voteFix', () {
    test('sends the API vote value and maps the response', () async {
      final api = _FakeFixesApiService(voteResponse: _fixJson);
      final repository = CommunityRepository(fixesApiService: api);

      final fix = await repository.voteFix('fix-1', FixVoteValue.like);

      expect(api.lastFixId, 'fix-1');
      expect(api.lastValue, 'like');
      expect(fix?.likes, 13);
      expect(fix?.myVote, FixVoteValue.like);
    });

    test('returns null on a DioException', () async {
      final repository = CommunityRepository(
        fixesApiService: _FakeFixesApiService(error: _dioError()),
      );

      expect(await repository.voteFix('fix-1', FixVoteValue.like), isNull);
    });
  });

  group('removeFixVote', () {
    test('returns true on success', () async {
      final repository = CommunityRepository(
        fixesApiService: _FakeFixesApiService(),
      );

      expect(await repository.removeFixVote('fix-1'), isTrue);
    });

    test('returns false on a DioException', () async {
      final repository = CommunityRepository(
        fixesApiService: _FakeFixesApiService(error: _dioError()),
      );

      expect(await repository.removeFixVote('fix-1'), isFalse);
    });
  });
}
