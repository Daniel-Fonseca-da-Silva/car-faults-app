import 'package:car_faults_app/ui/features/lookup/lookup_demo_display.dart';
import 'package:car_faults_app/ui/features/lookup/view_models/lookup_results_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toggleIssue expands and collapses an issue', () {
    final viewModel = LookupResultsViewModel();
    const issueId = 'gearbox-sync';

    expect(viewModel.isIssueExpanded(issueId), isFalse);

    viewModel.toggleIssue(issueId);
    expect(viewModel.isIssueExpanded(issueId), isTrue);

    viewModel.toggleIssue(issueId);
    expect(viewModel.isIssueExpanded(issueId), isFalse);
  });

  test('averageFor returns null when an issue has no reviews', () {
    final viewModel = LookupResultsViewModel();

    expect(viewModel.averageFor('floor-corrosion'), isNull);
  });

  test('averageFor returns the mean rating of the seeded reviews', () {
    final viewModel = LookupResultsViewModel();

    expect(viewModel.averageFor('gearbox-sync'), closeTo(4.33, 0.01));
  });

  test('hasOwnReview is true for the seeded issue with the demo user\'s '
      'review', () {
    final viewModel = LookupResultsViewModel();

    expect(viewModel.hasOwnReview('gearbox-sync'), isTrue);
    expect(viewModel.hasOwnReview('floor-corrosion'), isFalse);
  });

  test(
    'submitReview appends the demo user\'s review and notifies listeners',
    () {
      final viewModel = LookupResultsViewModel();
      var notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.submitReview(
        issueId: 'floor-corrosion',
        rating: 4,
        comment: 'Confirmed on my 96.',
      );

      expect(notified, isTrue);
      expect(viewModel.hasOwnReview('floor-corrosion'), isTrue);

      final own = viewModel.reviewsFor('floor-corrosion').single;
      expect(own.userId, LookupDemoDisplay.currentUserId);
      expect(own.rating, 4);
      expect(own.comment, 'Confirmed on my 96.');
    },
  );

  test('submitReview is a no-op when the demo user already reviewed the '
      'issue', () {
    final viewModel = LookupResultsViewModel();

    viewModel.submitReview(issueId: 'gearbox-sync', rating: 1);

    expect(viewModel.reviewsFor('gearbox-sync'), hasLength(3));
  });
}
