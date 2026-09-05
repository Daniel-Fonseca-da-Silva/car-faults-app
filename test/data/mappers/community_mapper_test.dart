import 'package:car_faults_app/data/mappers/community_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

const _reviewJson = {
  'id': 'review-1',
  'userId': 'user-1',
  'knownIssueId': 'issue-1',
  'rating': 4,
  'comment': 'Fixed it myself in a weekend.',
  'userName': 'Ricardo Moura',
  'userAvatarUrl': null,
  'createdAt': '2026-07-17T10:00:00.000Z',
  'updatedAt': '2026-07-17T10:00:00.000Z',
};

void main() {
  group('mapReviewResponse', () {
    test('maps every field and derives initials from userName', () {
      final review = mapReviewResponse(_reviewJson);

      expect(review.id, 'review-1');
      expect(review.userId, 'user-1');
      expect(review.userName, 'Ricardo Moura');
      expect(review.initials, 'RM');
      expect(review.rating, 4);
      expect(review.comment, 'Fixed it myself in a weekend.');
      expect(review.submittedAt, DateTime.parse('2026-07-17T10:00:00.000Z'));
    });

    test('falls back to empty name, "?" initials and empty comment when '
        'absent', () {
      final review = mapReviewResponse({
        ..._reviewJson,
        'userName': null,
        'comment': null,
      });

      expect(review.userName, '');
      expect(review.initials, '?');
      expect(review.comment, '');
    });

    test('derives a single-letter initial for a one-word name', () {
      final review = mapReviewResponse({..._reviewJson, 'userName': 'Ada'});

      expect(review.initials, 'A');
    });
  });

  group('mapReviewsPage', () {
    test('maps every item in the page', () {
      final reviews = mapReviewsPage({
        'items': [
          _reviewJson,
          {..._reviewJson, 'id': 'review-2', 'userName': 'Fábio Lopes'},
        ],
        'nextCursor': null,
      });

      expect(reviews, hasLength(2));
      expect(reviews[0].id, 'review-1');
      expect(reviews[1].initials, 'FL');
    });

    test('maps an empty page', () {
      expect(
        mapReviewsPage({'items': <dynamic>[], 'nextCursor': null}),
        isEmpty,
      );
    });
  });
}
