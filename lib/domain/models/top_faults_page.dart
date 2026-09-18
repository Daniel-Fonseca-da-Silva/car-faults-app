import 'top_fault.dart';

/// One cursor-paginated page of the platform's most-reported-faults ranking.
class TopFaultsPage {
  const TopFaultsPage({required this.items, required this.nextCursor});

  final List<TopFault> items;

  /// Opaque cursor for the next page, or null when this is the last page.
  final String? nextCursor;
}
