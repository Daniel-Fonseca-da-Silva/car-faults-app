import 'package:flutter/foundation.dart';

import '../../../../domain/models/issue_fix.dart';
import '../../../../domain/models/issue_review.dart';
import '../../../../domain/models/known_issue.dart';
import '../../../../domain/models/lookup_vehicle.dart';
import '../lookup_demo_display.dart';

/// Owns [LookupResultsView]'s matched vehicle and known issues, and the
/// interactive state of the known-issues accordion: which cards are
/// expanded, each issue's reviews, and each fix's expanded steps and ÚTIL?
/// vote.
///
/// [vehicle] and [issues] fall back to [LookupDemoDisplay] when not passed —
/// used by screens that don't yet navigate here with real search results
/// (garage, profile). Reviews are seeded from the passed [issues] and kept
/// in memory only — there is no review backend in this delivery, so
/// [submitReview] never persists. Votes work the same way: [voteLike] and
/// [voteDislike] only move a local flag, they never call an API.
class LookupResultsViewModel extends ChangeNotifier {
  LookupResultsViewModel({LookupVehicle? vehicle, List<KnownIssue>? issues})
    : vehicle = vehicle ?? LookupDemoDisplay.vehicle,
      _issues = issues ?? LookupDemoDisplay.issues {
    for (final issue in _issues) {
      _reviews[issue.id] = List<IssueReview>.from(issue.reviews);
      for (final fix in issue.fixes) {
        _fixes[fix.id] = fix;
      }
    }
  }

  final LookupVehicle vehicle;
  final List<KnownIssue> _issues;
  List<KnownIssue> get issues => List.unmodifiable(_issues);
  final Set<String> _expandedIssueIds = {};
  final Map<String, List<IssueReview>> _reviews = {};
  final Map<String, IssueFix> _fixes = {};
  final Set<String> _expandedFixIds = {};

  /// `true` = the demo user liked that fix, `false` = disliked it, absent =
  /// no vote yet.
  final Map<String, bool> _fixVotes = {};
  var _nextOwnReviewId = 0;

  bool isIssueExpanded(String id) => _expandedIssueIds.contains(id);

  void toggleIssue(String id) {
    if (!_expandedIssueIds.add(id)) {
      _expandedIssueIds.remove(id);
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

  bool hasOwnReview(String issueId) {
    return (_reviews[issueId] ?? const []).any(
      (review) => review.userId == LookupDemoDisplay.currentUserId,
    );
  }

  void submitReview({
    required String issueId,
    required int rating,
    String? comment,
  }) {
    if (hasOwnReview(issueId)) return;

    final reviews = _reviews.putIfAbsent(issueId, () => []);
    reviews.add(
      IssueReview(
        id: 'review-own-${_nextOwnReviewId++}',
        userId: LookupDemoDisplay.currentUserId,
        userName: LookupDemoDisplay.currentUserName,
        initials: LookupDemoDisplay.currentUserInitials,
        rating: rating,
        comment: comment ?? '',
        submittedAgo: '',
      ),
    );
    notifyListeners();
  }

  bool isFixExpanded(String fixId) => _expandedFixIds.contains(fixId);

  void toggleFixSteps(String fixId) {
    if (!_expandedFixIds.add(fixId)) {
      _expandedFixIds.remove(fixId);
    }
    notifyListeners();
  }

  /// Switches the vote to like, as if it were the first vote for that fix
  /// or the opposite side was previously active. Tapping the same side
  /// again is a no-op — undoing a vote is out of scope for this demo.
  void voteLike(String fixId) {
    _fixVotes[fixId] = true;
    notifyListeners();
  }

  void voteDislike(String fixId) {
    _fixVotes[fixId] = false;
    notifyListeners();
  }

  int likesFor(String fixId) {
    final base = _fixes[fixId]!.likes;
    return _fixVotes[fixId] == true ? base + 1 : base;
  }

  int dislikesFor(String fixId) {
    final base = _fixes[fixId]!.dislikes;
    return _fixVotes[fixId] == false ? base + 1 : base;
  }
}
