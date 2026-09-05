import 'package:car_faults_app/data/repositories/community_repository.dart';
import 'package:car_faults_app/data/services/comments_api_service.dart';
import 'package:car_faults_app/data/services/fixes_api_service.dart';
import 'package:car_faults_app/data/services/reviews_api_service.dart';
import 'package:car_faults_app/data/services/storage_api_service.dart';
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

class _FakeCommentsApiService extends CommentsApiService {
  _FakeCommentsApiService({this.listResponse, this.createResponse, this.error})
    : super(dio: Dio());

  final Map<String, dynamic>? listResponse;
  final Map<String, dynamic>? createResponse;
  final DioException? error;

  String? lastKnownIssueId;
  String? lastBody;
  String? lastImageUrl;

  @override
  Future<Map<String, dynamic>> list({required String knownIssueId}) async {
    lastKnownIssueId = knownIssueId;
    if (error != null) throw error!;
    return listResponse!;
  }

  @override
  Future<Map<String, dynamic>> create({
    required String knownIssueId,
    required String body,
    String? imageUrl,
  }) async {
    lastKnownIssueId = knownIssueId;
    lastBody = body;
    lastImageUrl = imageUrl;
    if (error != null) throw error!;
    return createResponse!;
  }
}

class _FakeStorageApiService extends StorageApiService {
  _FakeStorageApiService({this.uploadResponse, this.error}) : super(dio: Dio());

  final Map<String, dynamic>? uploadResponse;
  final DioException? error;

  String? lastFilePath;

  @override
  Future<Map<String, dynamic>> uploadCommentImage(String filePath) async {
    lastFilePath = filePath;
    if (error != null) throw error!;
    return uploadResponse!;
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

const _commentJson = {
  'id': 'comment-1',
  'userId': 'user-1',
  'knownIssueId': 'issue-1',
  'body': 'Fixed it myself',
  'imageUrl': null,
  'userName': 'Ada Lovelace',
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

  group('fetchComments', () {
    test('maps a successful page response', () async {
      final repository = CommunityRepository(
        commentsApiService: _FakeCommentsApiService(
          listResponse: {
            'items': [_commentJson],
            'nextCursor': null,
          },
        ),
      );

      final comments = await repository.fetchComments('issue-1');

      expect(comments, hasLength(1));
      expect(comments!.single.id, 'comment-1');
      expect(comments.single.userName, 'Ada Lovelace');
    });

    test('returns null on a DioException', () async {
      final repository = CommunityRepository(
        commentsApiService: _FakeCommentsApiService(error: _dioError()),
      );

      expect(await repository.fetchComments('issue-1'), isNull);
    });
  });

  group('submitComment', () {
    test('returns SubmitCommentSuccess with the mapped comment', () async {
      final api = _FakeCommentsApiService(createResponse: _commentJson);
      final repository = CommunityRepository(commentsApiService: api);

      final result = await repository.submitComment(
        knownIssueId: 'issue-1',
        body: 'Fixed it myself',
        imageUrl: 'https://cdn.example.test/photo.jpg',
      );

      expect(api.lastKnownIssueId, 'issue-1');
      expect(api.lastBody, 'Fixed it myself');
      expect(api.lastImageUrl, 'https://cdn.example.test/photo.jpg');
      expect(result, isA<SubmitCommentSuccess>());
      expect((result as SubmitCommentSuccess).comment.id, 'comment-1');
    });

    test('maps a DioException to SubmitCommentFailure', () async {
      final repository = CommunityRepository(
        commentsApiService: _FakeCommentsApiService(error: _dioError()),
      );

      final result = await repository.submitComment(
        knownIssueId: 'issue-1',
        body: 'Fixed it myself',
      );

      expect(result, isA<SubmitCommentFailure>());
    });
  });

  group('uploadCommentImage', () {
    test('returns the uploaded URL', () async {
      final api = _FakeStorageApiService(
        uploadResponse: {'url': 'https://cdn.example.test/photo.jpg'},
      );
      final repository = CommunityRepository(storageApiService: api);

      final url = await repository.uploadCommentImage('/tmp/photo.jpg');

      expect(api.lastFilePath, '/tmp/photo.jpg');
      expect(url, 'https://cdn.example.test/photo.jpg');
    });

    test('returns null on a DioException', () async {
      final repository = CommunityRepository(
        storageApiService: _FakeStorageApiService(error: _dioError()),
      );

      expect(await repository.uploadCommentImage('/tmp/photo.jpg'), isNull);
    });
  });
}
