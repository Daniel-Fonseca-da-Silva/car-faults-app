import 'package:car_faults_app/data/mappers/comments_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

const _commentJson = {
  'id': 'comment-1',
  'userId': 'user-1',
  'knownIssueId': 'issue-1',
  'body': 'Fixed it myself in a weekend.',
  'imageUrl': 'https://cdn.example.test/comments/user-1/photo.jpg',
  'userName': 'Ricardo Moura',
  'userAvatarUrl': null,
  'createdAt': '2026-07-17T10:00:00.000Z',
  'updatedAt': '2026-07-17T10:00:00.000Z',
};

void main() {
  group('mapCommentResponse', () {
    test('maps every field and derives initials from userName', () {
      final comment = mapCommentResponse(_commentJson);

      expect(comment.id, 'comment-1');
      expect(comment.userId, 'user-1');
      expect(comment.userName, 'Ricardo Moura');
      expect(comment.initials, 'RM');
      expect(comment.body, 'Fixed it myself in a weekend.');
      expect(
        comment.imageUrl,
        'https://cdn.example.test/comments/user-1/photo.jpg',
      );
      expect(comment.submittedAt, DateTime.parse('2026-07-17T10:00:00.000Z'));
    });

    test('falls back to empty name, "?" initials and null image when '
        'absent', () {
      final comment = mapCommentResponse({
        ..._commentJson,
        'userName': null,
        'imageUrl': null,
      });

      expect(comment.userName, '');
      expect(comment.initials, '?');
      expect(comment.imageUrl, isNull);
    });

    test('derives a single-letter initial for a one-word name', () {
      final comment = mapCommentResponse({..._commentJson, 'userName': 'Ada'});

      expect(comment.initials, 'A');
    });
  });

  group('mapCommentsPage', () {
    test('maps every item in the page', () {
      final comments = mapCommentsPage({
        'items': [
          _commentJson,
          {..._commentJson, 'id': 'comment-2', 'userName': 'Fábio Lopes'},
        ],
        'nextCursor': null,
      });

      expect(comments, hasLength(2));
      expect(comments[0].id, 'comment-1');
      expect(comments[1].initials, 'FL');
    });

    test('maps an empty page', () {
      expect(
        mapCommentsPage({'items': <dynamic>[], 'nextCursor': null}),
        isEmpty,
      );
    });
  });
}
