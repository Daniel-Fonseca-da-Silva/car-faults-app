/// A community rating of a [KnownIssue].
///
/// [initials] backs the avatar fallback. [submittedAt] is rendered as a
/// short relative-time label (e.g. `há 2 d`) via `relativeTimeLabel`.
class IssueReview {
  const IssueReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.initials,
    required this.rating,
    required this.comment,
    required this.submittedAt,
  });

  final String id;
  final String userId;
  final String userName;
  final String initials;
  final int rating;
  final String comment;
  final DateTime submittedAt;
}
