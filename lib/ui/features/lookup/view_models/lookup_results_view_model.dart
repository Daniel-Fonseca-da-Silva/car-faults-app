import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/community_repository.dart';
import '../../../../domain/models/fix_vote_value.dart';
import '../../../../domain/models/issue_fix.dart';
import '../../../../domain/models/issue_review.dart';
import '../../../../domain/models/known_issue.dart';
import '../../../../domain/models/lookup_vehicle.dart';
import '../lookup_demo_display.dart';

/// Owns [LookupResultsView]'s matched vehicle and known issues, and the
/// interactive state of the known-issues accordion: which cards are
/// expanded, each issue's reviews and each fix's expanded steps and vote.
///
/// [vehicle] and [issues] fall back to [LookupDemoDisplay] when not passed —
/// used by screens that don't yet navigate here with real search results
/// (garage, profile). Reviews are seeded from the passed [issues] and then
/// lazily refreshed from [CommunityRepository] the first time each issue is
/// expanded (and cached — see [toggleIssue]); fix votes always go through
/// [CommunityRepository].
class LookupResultsViewModel extends ChangeNotifier {
  LookupResultsViewModel({
    LookupVehicle? vehicle,
    List<KnownIssue>? issues,
    CommunityRepository? repository,
  }) : vehicle = vehicle ?? LookupDemoDisplay.vehicle,
       _issues = issues ?? LookupDemoDisplay.issues,
       _repository = repository ?? CommunityRepository() {
    for (final issue in _issues) {
      _reviews[issue.id] = List<IssueReview>.from(issue.reviews);
      for (final fix in issue.fixes) {
        _fixes[fix.id] = fix;
      }
    }
  }

  final CommunityRepository _repository;
  final LookupVehicle vehicle;
  final List<KnownIssue> _issues;
  List<KnownIssue> get issues => List.unmodifiable(_issues);
  final Set<String> _expandedIssueIds = {};
  final Map<String, List<IssueReview>> _reviews = {};
  final Set<String> _loadedReviewIds = {};
  final Set<String> _loadingReviewIds = {};
  final Map<String, IssueFix> _fixes = {};
  final Set<String> _expandedFixIds = {};

  bool isIssueExpanded(String id) => _expandedIssueIds.contains(id);

  /// Expands or collapses [id]. The first time it expands, this triggers a
  /// `GET /v1/reviews` fetch in the background — see [isLoadingReviews] —
  /// whose result replaces the seeded reviews once it lands (or is dropped
  /// on failure, leaving whatever was already shown).
  void toggleIssue(String id) {
    final isExpanding = !_expandedIssueIds.contains(id);
    if (isExpanding) {
      _expandedIssueIds.add(id);
      if (!_loadedReviewIds.contains(id)) {
        unawaited(_loadReviews(id));
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
}
