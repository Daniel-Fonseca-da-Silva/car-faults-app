/// Aggregate usage counters shown in the profile stats grid.
class UserStats {
  const UserStats({
    required this.searchesCount,
    required this.defectsConsultedCount,
    required this.savedVehiclesCount,
    required this.votesCount,
  });

  final int searchesCount;
  final int defectsConsultedCount;
  final int savedVehiclesCount;
  final int votesCount;
}
