import 'package:flutter/foundation.dart';

import '../../../../domain/models/issue_review.dart';
import '../../../../domain/models/known_issue.dart';
import '../lookup_demo_display.dart';

/// Owns the interactive state of [LookupResultsView]'s known-issues
/// accordion: which cards are expanded, and each issue's reviews.
///
/// Reviews are seeded from [issues] and kept in memory only — there is no
/// review backend in this delivery, so [submitReview] never persists.
class LookupResultsViewModel extends ChangeNotifier {
  LookupResultsViewModel({List<KnownIssue>? issues})
    : _issues = issues ?? LookupDemoDisplay.issues {
    for (final issue in _issues) {
      _reviews[issue.id] = List<IssueReview>.from(issue.reviews);
    }
  }

  final List<KnownIssue> _issues;
  final Set<String> _expandedIssueIds = {};
  final Map<String, List<IssueReview>> _reviews = {};
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
}
