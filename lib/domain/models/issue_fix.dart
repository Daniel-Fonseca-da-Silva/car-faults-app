import 'fix_vote_value.dart';

/// A community-submitted fix for a [KnownIssue], with an ordered how-to and
/// a rough cost.
class IssueFix {
  const IssueFix({
    required this.id,
    required this.summary,
    required this.steps,
    required this.estimatedCostEur,
    required this.likes,
    required this.dislikes,
    this.myVote,
  });

  final String id;
  final String summary;
  final List<String> steps;
  final int estimatedCostEur;
  final int likes;
  final int dislikes;

  /// The signed-in user's vote on this fix, or `null` when they haven't
  /// voted — including whenever this [IssueFix] came from `GET /v1/lookups`,
  /// which doesn't report the caller's vote at all.
  final FixVoteValue? myVote;
}
