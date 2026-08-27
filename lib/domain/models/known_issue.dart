import 'issue_fix.dart';
import 'issue_review.dart';
import 'issue_severity.dart';

/// A known fault reported for a [LookupVehicle], with its community fixes
/// and reviews.
///
/// [typicalKm] and [mileageNote] are mutually descriptive: an issue tied to a
/// mileage threshold sets [typicalKm], while one that is age-related instead
/// (e.g. corrosion) leaves it `null` and explains why via [mileageNote].
class KnownIssue {
  const KnownIssue({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    this.typicalKm,
    this.mileageNote,
    required this.sources,
    required this.fixes,
    required this.reviews,
  });

  final String id;
  final String title;
  final String description;
  final IssueSeverity severity;
  final int? typicalKm;
  final String? mileageNote;
  final List<String> sources;
  final List<IssueFix> fixes;
  final List<IssueReview> reviews;
}
