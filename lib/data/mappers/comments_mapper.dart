import '../../domain/models/comment.dart';

/// Maps a `CommentResponseDto` JSON body to [Comment].
Comment mapCommentResponse(Map<String, dynamic> json) {
  final userName = json['userName'] as String?;

  return Comment(
    id: json['id'] as String,
    userId: json['userId'] as String,
    userName: userName ?? '',
    initials: _initialsFor(userName),
    body: json['body'] as String,
    imageUrl: json['imageUrl'] as String?,
    submittedAt: DateTime.parse(json['createdAt'] as String),
  );
}

/// Maps a `CommentsPageDto` JSON body (`GET /v1/comments`) to a flat list of
/// [Comment] — pagination is not surfaced to the UI in this delivery.
List<Comment> mapCommentsPage(Map<String, dynamic> json) {
  final items = json['items'] as List<dynamic>;
  return items
      .map((item) => mapCommentResponse(item as Map<String, dynamic>))
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
