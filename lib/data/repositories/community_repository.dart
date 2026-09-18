import 'package:dio/dio.dart';

import '../../domain/models/comment.dart';
import '../../domain/models/fix_vote_value.dart';
import '../../domain/models/issue_fix.dart';
import '../../domain/models/issue_review.dart';
import '../../domain/models/report_reason.dart';
import '../mappers/comments_mapper.dart';
import '../mappers/community_mapper.dart';
import '../mappers/lookup_mapper.dart';
import '../services/api_client.dart';
import '../services/comments_api_service.dart';
import '../services/fixes_api_service.dart';
import '../services/reports_api_service.dart';
import '../services/reviews_api_service.dart';
import '../services/secure_token_storage.dart';
import '../services/storage_api_service.dart';

/// Outcome of [CommunityRepository.submitReview].
sealed class SubmitReviewResult {
  const SubmitReviewResult();
}

class SubmitReviewSuccess extends SubmitReviewResult {
  const SubmitReviewSuccess(this.review);
  final IssueReview review;
}

/// The signed-in user already reviewed this known issue (`409 Conflict`).
class SubmitReviewDuplicate extends SubmitReviewResult {
  const SubmitReviewDuplicate();
}

class SubmitReviewFailure extends SubmitReviewResult {
  const SubmitReviewFailure();
}

/// Outcome of [CommunityRepository.submitComment].
sealed class SubmitCommentResult {
  const SubmitCommentResult();
}

class SubmitCommentSuccess extends SubmitCommentResult {
  const SubmitCommentSuccess(this.comment);
  final Comment comment;
}

class SubmitCommentFailure extends SubmitCommentResult {
  const SubmitCommentFailure();
}

/// Outcome of [CommunityRepository.reportComment]/[reportReview].
sealed class SubmitReportResult {
  const SubmitReportResult();
}

class SubmitReportSuccess extends SubmitReportResult {
  const SubmitReportSuccess();
}

/// The signed-in user already reported this content (`409 Conflict`).
class SubmitReportDuplicate extends SubmitReportResult {
  const SubmitReportDuplicate();
}

class SubmitReportFailure extends SubmitReportResult {
  const SubmitReportFailure();
}

/// Persists community reviews, comments, fix votes and content reports via
/// `car-faults-api`: listing and creating reviews/comments for a known
/// issue, uploading a comment's image, voting/unvoting on a fix, and
/// reporting a comment or review for moderation.
///
/// Every parameter can be overridden — tests subclass [CommunityRepository]
/// and override individual methods instead of injecting fakes here, but the
/// seam is kept for callers that do want to swap a dependency.
class CommunityRepository {
  CommunityRepository({
    ReviewsApiService? reviewsApiService,
    FixesApiService? fixesApiService,
    CommentsApiService? commentsApiService,
    StorageApiService? storageApiService,
    ReportsApiService? reportsApiService,
    SecureTokenStorage? tokenStorage,
  }) : _reviewsApiService =
           reviewsApiService ??
           ReviewsApiService(
             dio: buildApiDio(
               tokenStorage: tokenStorage ?? SecureTokenStorage(),
             ),
           ),
       _fixesApiService =
           fixesApiService ??
           FixesApiService(
             dio: buildApiDio(
               tokenStorage: tokenStorage ?? SecureTokenStorage(),
             ),
           ),
       _commentsApiService =
           commentsApiService ??
           CommentsApiService(
             dio: buildApiDio(
               tokenStorage: tokenStorage ?? SecureTokenStorage(),
             ),
           ),
       _storageApiService =
           storageApiService ??
           StorageApiService(
             dio: buildApiDio(
               tokenStorage: tokenStorage ?? SecureTokenStorage(),
             ),
           ),
       _reportsApiService =
           reportsApiService ??
           ReportsApiService(
             dio: buildApiDio(
               tokenStorage: tokenStorage ?? SecureTokenStorage(),
             ),
           );

  final ReviewsApiService _reviewsApiService;
  final FixesApiService _fixesApiService;
  final CommentsApiService _commentsApiService;
  final StorageApiService _storageApiService;
  final ReportsApiService _reportsApiService;

  /// `GET /v1/reviews?knownIssueId=` — public. Returns `null` on failure so
  /// callers can leave whatever reviews are already shown in place instead
  /// of clearing them.
  Future<List<IssueReview>?> fetchReviews(String knownIssueId) async {
    try {
      final json = await _reviewsApiService.list(knownIssueId: knownIssueId);
      return mapReviewsPage(json);
    } on DioException {
      return null;
    }
  }

  /// `POST /v1/reviews` — JWT required.
  Future<SubmitReviewResult> submitReview({
    required String knownIssueId,
    required int rating,
    String? comment,
  }) async {
    try {
      final json = await _reviewsApiService.create(
        knownIssueId: knownIssueId,
        rating: rating,
        comment: comment,
      );
      return SubmitReviewSuccess(mapReviewResponse(json));
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) return const SubmitReviewDuplicate();
      return const SubmitReviewFailure();
    }
  }

  /// `POST /v1/fixes/:id/vote` — JWT required. Returns `null` on failure.
  Future<IssueFix?> voteFix(String fixId, FixVoteValue value) async {
    try {
      final json = await _fixesApiService.vote(
        fixId: fixId,
        value: fixVoteValueApiValue(value),
      );
      return mapFixResponse(json);
    } on DioException {
      return null;
    }
  }

  /// `DELETE /v1/fixes/:id/vote` — JWT required.
  Future<bool> removeFixVote(String fixId) async {
    try {
      await _fixesApiService.removeVote(fixId: fixId);
      return true;
    } on DioException {
      return false;
    }
  }

  /// `GET /v1/comments?knownIssueId=` — public. Returns `null` on failure so
  /// callers can leave whatever comments are already shown in place instead
  /// of clearing them.
  Future<List<Comment>?> fetchComments(String knownIssueId) async {
    try {
      final json = await _commentsApiService.list(knownIssueId: knownIssueId);
      return mapCommentsPage(json);
    } on DioException {
      return null;
    }
  }

  /// `POST /v1/comments` — JWT required.
  Future<SubmitCommentResult> submitComment({
    required String knownIssueId,
    required String body,
    String? imageUrl,
  }) async {
    try {
      final json = await _commentsApiService.create(
        knownIssueId: knownIssueId,
        body: body,
        imageUrl: imageUrl,
      );
      return SubmitCommentSuccess(mapCommentResponse(json));
    } on DioException {
      return const SubmitCommentFailure();
    }
  }

  /// `POST /v1/storage/comment-images` — JWT required. Returns the uploaded
  /// image's public URL, or `null` on failure.
  Future<String?> uploadCommentImage(String filePath) async {
    try {
      final json = await _storageApiService.uploadCommentImage(filePath);
      return json['url'] as String;
    } on DioException {
      return null;
    }
  }

  /// `POST /v1/reports` — JWT required. Reports [commentId] (its text and
  /// attached photo, if any) for moderation.
  Future<SubmitReportResult> reportComment({
    required String commentId,
    required ReportReason reason,
    String? details,
  }) => _submitReport(
    contentType: 'comment',
    contentId: commentId,
    reason: reason,
    details: details,
  );

  /// `POST /v1/reports` — JWT required. Reports [reviewId] for moderation.
  Future<SubmitReportResult> reportReview({
    required String reviewId,
    required ReportReason reason,
    String? details,
  }) => _submitReport(
    contentType: 'review',
    contentId: reviewId,
    reason: reason,
    details: details,
  );

  Future<SubmitReportResult> _submitReport({
    required String contentType,
    required String contentId,
    required ReportReason reason,
    String? details,
  }) async {
    try {
      await _reportsApiService.create(
        contentType: contentType,
        contentId: contentId,
        reason: reportReasonApiValue(reason),
        details: details,
      );
      return const SubmitReportSuccess();
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) return const SubmitReportDuplicate();
      return const SubmitReportFailure();
    }
  }
}
