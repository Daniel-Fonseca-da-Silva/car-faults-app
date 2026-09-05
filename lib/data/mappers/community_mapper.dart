import '../../domain/models/issue_review.dart';

/// Maps a `ReviewResponseDto` JSON body to [IssueReview].
IssueReview mapReviewResponse(Map<String, dynamic> json) {
  final userName = json['userName'] as String?;

  return IssueReview(
    id: json['id'] as String,
    userId: json['userId'] as String,
    userName: userName ?? '',
    initials: _initialsFor(userName),
    rating: json['rating'] as int,
    comment: (json['comment'] as String?) ?? '',
    submittedAt: DateTime.parse(json['createdAt'] as String),
  );
}

/// Maps a `ReviewsPageDto` JSON body (`GET /v1/reviews`) to a flat list of
/// [IssueReview] — pagination is not surfaced to the UI in this delivery.
List<IssueReview> mapReviewsPage(Map<String, dynamic> json) {
  final items = json['items'] as List<dynamic>;
  return items
      .map((item) => mapReviewResponse(item as Map<String, dynamic>))
      .toList();
}

/// Avatar-fallback initials from a display name, e.g. `'Ricardo Moura'` ->
/// `'RM'`. Falls back to `'?'` for a missing or blank name.
String _initialsFor(String? name) {
  final parts = (name ?? '').trim().split(RegExp(r'\s+'))
    ..removeWhere((part) => part.isEmpty);
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}
