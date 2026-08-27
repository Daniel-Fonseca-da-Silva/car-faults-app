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
  });

  final String id;
  final String summary;
  final List<String> steps;
  final int estimatedCostEur;
  final int likes;
  final int dislikes;
}
