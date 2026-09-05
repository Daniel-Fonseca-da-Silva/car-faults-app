import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/activity_log_repository.dart';
import '../../../../data/repositories/community_repository.dart';
import '../../../../data/repositories/garage_repository.dart';
import '../../../../domain/models/comment.dart';
import '../../../../domain/models/fix_vote_value.dart';
import '../../../../domain/models/issue_fix.dart';
import '../../../../domain/models/issue_review.dart';
import '../../../../domain/models/known_issue.dart';
import '../../../../domain/models/lookup_vehicle.dart';
import '../lookup_demo_display.dart';

/// Owns [LookupResultsView]'s matched vehicle and known issues, and the
/// interactive state of the known-issues accordion: which cards are
/// expanded, each issue's reviews/comments and each fix's expanded steps and
/// vote.
///
/// [vehicle] and [issues] fall back to [LookupDemoDisplay] when not passed —
/// used by screens that don't yet navigate here with real search results
/// (garage, profile). Reviews are seeded from the passed [issues] and then,
/// like comments, lazily (re)loaded from [CommunityRepository] the first
/// time each issue is expanded (and cached — see [toggleIssue]); fix votes
/// always go through [CommunityRepository]. [searchedYear] is the exact
/// year the user searched for (distinct from [LookupVehicle.yearFrom]'s
/// generation range) and, together with [vehicle]'s catalog id, identifies
/// the vehicle for [GarageRepository] add-to-garage calls.
class LookupResultsViewModel extends ChangeNotifier {
  LookupResultsViewModel({
    LookupVehicle? vehicle,
    List<KnownIssue>? issues,
    this.searchedYear,
    CommunityRepository? repository,
    GarageRepository? garageRepository,
    ActivityLogRepository? activityLogRepository,
  }) : vehicle = vehicle ?? LookupDemoDisplay.vehicle,
       _issues = issues ?? LookupDemoDisplay.issues,
       _repository = repository ?? CommunityRepository(),
       _garageRepository = garageRepository ?? GarageRepository(),
       _activityLogRepository =
           activityLogRepository ?? ActivityLogRepository() {
    for (final issue in _issues) {
      _reviews[issue.id] = List<IssueReview>.from(issue.reviews);
      for (final fix in issue.fixes) {
        _fixes[fix.id] = fix;
      }
    }
  }

  final CommunityRepository _repository;
  final GarageRepository _garageRepository;
  final ActivityLogRepository _activityLogRepository;
  final LookupVehicle vehicle;
  final int? searchedYear;
  final List<KnownIssue> _issues;
  List<KnownIssue> get issues => List.unmodifiable(_issues);
  final Set<String> _expandedIssueIds = {};
  final Map<String, List<IssueReview>> _reviews = {};
  final Set<String> _loadedReviewIds = {};
  final Set<String> _loadingReviewIds = {};
  final Map<String, List<Comment>> _comments = {};
  final Set<String> _loadedCommentIds = {};
  final Set<String> _loadingCommentIds = {};
  final Set<String> _recordedDefectConsultedIds = {};
  final Map<String, IssueFix> _fixes = {};
  final Set<String> _expandedFixIds = {};

  bool isIssueExpanded(String id) => _expandedIssueIds.contains(id);

  /// Expands or collapses [id]. The first time it expands, this triggers
  /// `GET /v1/reviews` and `GET /v1/comments` fetches in the background —
  /// see [isLoadingReviews]/[isLoadingComments] — whose results replace the
  /// seeded reviews/comments once they land (or are dropped on failure,
  /// leaving whatever was already shown) — and records a
  /// `defect_consulted` activity log (once per issue per session).
  void toggleIssue(String id) {
    final isExpanding = !_expandedIssueIds.contains(id);
    if (isExpanding) {
      _expandedIssueIds.add(id);
      if (!_loadedReviewIds.contains(id)) {
        unawaited(_loadReviews(id));
      }
      if (!_loadedCommentIds.contains(id)) {
        unawaited(_loadComments(id));
      }
      if (_recordedDefectConsultedIds.add(id)) {
        unawaited(_activityLogRepository.recordDefectConsulted(id));
      }
    } else {
      _expandedIssueIds.remove(id);
    }
    notifyListeners();
  }

  bool isLoadingReviews(String issueId) => _loadingReviewIds.contains(issueId);

  Future<void> _loadReviews(String issueId) async {
    _loadingReviewIds.add(issueId);
    notifyListeners();

    final reviews = await _repository.fetchReviews(issueId);

    _loadingReviewIds.remove(issueId);
    if (reviews != null) {
      _reviews[issueId] = reviews;
      _loadedReviewIds.add(issueId);
    }
    notifyListeners();
  }

  List<IssueReview> reviewsFor(String issueId) {
    return List.unmodifiable(_reviews[issueId] ?? const []);
  }

  double? averageFor(String issueId) {
    final reviews = _reviews[issueId];
    if (reviews == null || reviews.isEmpty) return null;

    final total = reviews.fold<int>(0, (sum, review) => sum + review.rating);
    return total / reviews.length;
  }

  /// Whether [currentUserId] (the signed-in user, or `null` when signed
  /// out) already has a review among [reviewsFor].
  bool hasOwnReview(String issueId, String? currentUserId) {
    if (currentUserId == null) return false;
    return (_reviews[issueId] ?? const []).any(
      (review) => review.userId == currentUserId,
    );
  }

  /// `POST /v1/reviews`. On [SubmitReviewSuccess], the new review is
  /// appended to [reviewsFor] without a full refetch.
  Future<SubmitReviewResult> submitReview({
    required String issueId,
    required int rating,
    String? comment,
  }) async {
    final result = await _repository.submitReview(
      knownIssueId: issueId,
      rating: rating,
      comment: comment,
    );
    if (result is SubmitReviewSuccess) {
      final reviews = _reviews.putIfAbsent(issueId, () => []);
      reviews.add(result.review);
      _loadedReviewIds.add(issueId);
      notifyListeners();
    }
    return result;
  }

  bool isLoadingComments(String issueId) =>
      _loadingCommentIds.contains(issueId);

  Future<void> _loadComments(String issueId) async {
    _loadingCommentIds.add(issueId);
    notifyListeners();

    final comments = await _repository.fetchComments(issueId);

    _loadingCommentIds.remove(issueId);
    if (comments != null) {
      _comments[issueId] = comments;
      _loadedCommentIds.add(issueId);
    }
    notifyListeners();
  }

  List<Comment> commentsFor(String issueId) {
    return List.unmodifiable(_comments[issueId] ?? const []);
  }

  /// `POST /v1/comments`. On [SubmitCommentSuccess], the new comment is
  /// appended to [commentsFor] without a full refetch.
  Future<SubmitCommentResult> submitComment({
    required String issueId,
    required String body,
    String? imageUrl,
  }) async {
    final result = await _repository.submitComment(
      knownIssueId: issueId,
      body: body,
      imageUrl: imageUrl,
    );
    if (result is SubmitCommentSuccess) {
      final comments = _comments.putIfAbsent(issueId, () => []);
      comments.add(result.comment);
      _loadedCommentIds.add(issueId);
      notifyListeners();
    }
    return result;
  }

  /// `POST /v1/storage/comment-images`. Returns the uploaded image's public
  /// URL, or `null` on failure.
  Future<String?> uploadCommentImage(String filePath) {
    return _repository.uploadCommentImage(filePath);
  }

  bool isFixExpanded(String fixId) => _expandedFixIds.contains(fixId);

  void toggleFixSteps(String fixId) {
    if (!_expandedFixIds.add(fixId)) {
      _expandedFixIds.remove(fixId);
    }
    notifyListeners();
  }

  FixVoteValue? myVoteFor(String fixId) => _fixes[fixId]?.myVote;

  int likesFor(String fixId) => _fixes[fixId]!.likes;

  int dislikesFor(String fixId) => _fixes[fixId]!.dislikes;

  /// Likes [fixId] via `POST /v1/fixes/:id/vote`, or removes an existing
  /// like via `DELETE /v1/fixes/:id/vote` when tapped again.
  Future<void> voteLike(String fixId) => _toggleVote(fixId, FixVoteValue.like);

  /// Dislikes [fixId], or removes an existing dislike when tapped again —
  /// see [voteLike].
  Future<void> voteDislike(String fixId) =>
      _toggleVote(fixId, FixVoteValue.dislike);

  Future<void> _toggleVote(String fixId, FixVoteValue value) async {
    final current = _fixes[fixId];
    if (current == null) return;

    if (current.myVote == value) {
      final removed = await _repository.removeFixVote(fixId);
      if (!removed) return;
      _fixes[fixId] = IssueFix(
        id: current.id,
        summary: current.summary,
        steps: current.steps,
        estimatedCostEur: current.estimatedCostEur,
        likes: value == FixVoteValue.like ? current.likes - 1 : current.likes,
        dislikes: value == FixVoteValue.dislike
            ? current.dislikes - 1
            : current.dislikes,
      );
    } else {
      final updated = await _repository.voteFix(fixId, value);
      if (updated == null) return;
      _fixes[fixId] = updated;
    }
    notifyListeners();
  }

  /// The year identifying [vehicle] for garage calls: the exact year
  /// searched for, or [LookupVehicle.yearFrom] as a fallback for screens
  /// that navigate here without a search (garage, profile).
  int get _garageYear => searchedYear ?? vehicle.yearFrom;

  bool? _isInGarage;

  /// Whether [vehicle] is already in the signed-in user's garage. `null`
  /// until [checkGarageStatus] resolves (or when signed out / not checked).
  bool? get isInGarage => _isInGarage;

  bool _isCheckingGarageStatus = false;
  bool get isCheckingGarageStatus => _isCheckingGarageStatus;

  bool _isAddingToGarage = false;
  bool get isAddingToGarage => _isAddingToGarage;

  /// `GET /v1/user-vehicles/status`. No-op once [isInGarage] is already
  /// known, so the View can call this every time it becomes visible.
  Future<void> checkGarageStatus() async {
    if (_isCheckingGarageStatus || _isInGarage != null) return;

    _isCheckingGarageStatus = true;
    notifyListeners();

    final owned = await _garageRepository.checkGarageStatus(
      vehicleModelId: vehicle.id,
      year: _garageYear,
    );

    _isCheckingGarageStatus = false;
    if (owned != null) _isInGarage = owned;
    notifyListeners();
  }

  /// `POST /v1/user-vehicles`, adding [vehicle] to the signed-in user's
  /// garage. On [AddToGarageSuccess] or [AddToGarageDuplicate], [isInGarage]
  /// flips to `true`.
  Future<AddToGarageResult> addToGarage() async {
    _isAddingToGarage = true;
    notifyListeners();

    final result = await _garageRepository.addVehicle(
      vehicleModelId: vehicle.id,
      year: _garageYear,
    );

    _isAddingToGarage = false;
    if (result is AddToGarageSuccess || result is AddToGarageDuplicate) {
      _isInGarage = true;
    }
    notifyListeners();
    return result;
  }
}
