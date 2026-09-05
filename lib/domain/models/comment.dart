/// A community comment on a [KnownIssue], optionally with an attached image.
///
/// [initials] backs the avatar fallback, mirroring [IssueReview].
class Comment {
  const Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.initials,
    required this.body,
    required this.imageUrl,
    required this.submittedAt,
  });

  final String id;
  final String userId;
  final String userName;
  final String initials;
  final String body;
  final String? imageUrl;
  final DateTime submittedAt;
}
