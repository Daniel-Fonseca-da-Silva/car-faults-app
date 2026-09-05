import 'package:car_faults_app/l10n/app_localizations.dart';

const _minute = Duration(minutes: 1);
const _hour = Duration(hours: 1);
const _day = Duration(days: 1);

/// Formats [submittedAt] as a short, localized relative-time label (e.g.
/// `há 2 d`), as shown next to a community review.
String relativeTimeLabel(DateTime submittedAt, AppLocalizations l10n) {
  final elapsed = DateTime.now().difference(submittedAt);

  if (elapsed < _minute) return l10n.lookupReviewsJustNow;
  if (elapsed < _hour) return l10n.lookupReviewsMinutesAgo(elapsed.inMinutes);
  if (elapsed < _day) return l10n.lookupReviewsHoursAgo(elapsed.inHours);
  return l10n.lookupReviewsDaysAgo(elapsed.inDays);
}
