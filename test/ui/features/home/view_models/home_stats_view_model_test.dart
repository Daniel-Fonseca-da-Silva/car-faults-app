import 'package:car_faults_app/data/repositories/platform_repository.dart';
import 'package:car_faults_app/domain/models/platform_stats.dart';
import 'package:car_faults_app/ui/features/home/view_models/home_stats_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePlatformRepository extends PlatformRepository {
  _FakePlatformRepository({this.stats, this.error});

  final PlatformStats? stats;
  final Object? error;
  var calls = 0;

  @override
  Future<PlatformStats> getStats() async {
    calls++;
    if (error != null) throw error!;
    return stats!;
  }
}

void main() {
  const sampleStats = PlatformStats(
    reportsCount: 10,
    vehiclesCount: 20,
    faultsCount: 30,
  );

  test('load sets stats on success', () async {
    final viewModel = HomeStatsViewModel(
      repository: _FakePlatformRepository(stats: sampleStats),
    );
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    await viewModel.load();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.hasError, isFalse);
    expect(viewModel.stats, sampleStats);
    expect(notifications, 2);
  });

  test('load sets hasError when the repository throws', () async {
    final viewModel = HomeStatsViewModel(
      repository: _FakePlatformRepository(error: Exception('offline')),
    );

    await viewModel.load();

    expect(viewModel.hasError, isTrue);
    expect(viewModel.stats, isNull);
    expect(viewModel.isLoading, isFalse);
  });

  test('load ignores a second call while one is in flight', () async {
    final repository = _FakePlatformRepository(stats: sampleStats);
    final viewModel = HomeStatsViewModel(repository: repository);

    final first = viewModel.load();
    final second = viewModel.load();
    await first;
    await second;

    expect(repository.calls, 1);
  });
}
