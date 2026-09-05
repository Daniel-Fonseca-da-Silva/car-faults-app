/// Public platform-wide figures shown in the home stats bar.
class PlatformStats {
  const PlatformStats({
    required this.reportsCount,
    required this.vehiclesCount,
    required this.faultsCount,
  });

  final int reportsCount;
  final int vehiclesCount;
  final int faultsCount;
}
