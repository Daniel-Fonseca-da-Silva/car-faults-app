import '../../../data/repositories/lookup_repository.dart';
import '../../../l10n/app_localizations.dart';

/// Localized message for a [LookupFailureReason], shown in a SnackBar by
/// every screen that calls [LookupRepository.search] (home search,
/// favorites).
String lookupFailureMessage(AppLocalizations l10n, LookupFailureReason reason) {
  return switch (reason) {
    LookupFailureReason.rateLimited => l10n.homeSearchErrorRateLimited,
    LookupFailureReason.unavailable => l10n.homeSearchErrorUnavailable,
    LookupFailureReason.notFound => l10n.homeSearchErrorNotFound,
    LookupFailureReason.network ||
    LookupFailureReason.unknown => l10n.homeSearchErrorGeneric,
  };
}
