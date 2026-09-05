import 'package:car_faults_app/data/repositories/platform_repository.dart';
import 'package:car_faults_app/domain/models/app_locale.dart';
import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:car_faults_app/domain/models/top_fault.dart';
import 'package:car_faults_app/ui/features/home/view_models/home_top_faults_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePlatformRepository extends PlatformRepository {
  _FakePlatformRepository({this.faults, this.error});

  List<TopFault>? faults;
  Object? error;
  var calls = 0;
  AppLocale? lastLocale;

  @override
  Future<List<TopFault>> getTopFaults({
    required AppLocale locale,
    int limit = 6,
  }) async {
    calls++;
    lastLocale = locale;
    if (error != null) throw error!;
    return faults!;
  }
}

const _sampleFaults = [
  TopFault(
    id: 'f1',
    title: 'Oil leak',
    severity: IssueSeverity.medium,
    reportCount: 12,
    vehicleBrand: 'BMW',
    vehicleModel: '320d',
    vehicleYearFrom: 2012,
  ),
];

void main() {
  test('load sets faults on success', () async {
    final repository = _FakePlatformRepository(faults: _sampleFaults);
    final viewModel = HomeTopFaultsViewModel(repository: repository);

    await viewModel.load(AppLocale.pt);

    expect(viewModel.faults, _sampleFaults);
    expect(viewModel.hasError, isFalse);
    expect(repository.lastLocale, AppLocale.pt);
  });

  test('load sets hasError when the repository throws', () async {
    final viewModel = HomeTopFaultsViewModel(
      repository: _FakePlatformRepository(error: Exception('offline')),
    );

    await viewModel.load(AppLocale.en);

    expect(viewModel.hasError, isTrue);
    expect(viewModel.faults, isEmpty);
  });

  test('load skips a refetch for the same locale after success', () async {
    final repository = _FakePlatformRepository(faults: _sampleFaults);
    final viewModel = HomeTopFaultsViewModel(repository: repository);

    await viewModel.load(AppLocale.pt);
    await viewModel.load(AppLocale.pt);

    expect(repository.calls, 1);
  });

  test('load refetches after an error even for the same locale', () async {
    final repository = _FakePlatformRepository(error: Exception('offline'));
    final viewModel = HomeTopFaultsViewModel(repository: repository);

    await viewModel.load(AppLocale.es);
    repository
      ..error = null
      ..faults = _sampleFaults;
    await viewModel.load(AppLocale.es);

    expect(repository.calls, 2);
    expect(viewModel.hasError, isFalse);
    expect(viewModel.faults, _sampleFaults);
  });

  test('load ignores a second call while one is in flight', () async {
    final repository = _FakePlatformRepository(faults: _sampleFaults);
    final viewModel = HomeTopFaultsViewModel(repository: repository);

    final first = viewModel.load(AppLocale.pt);
    final second = viewModel.load(AppLocale.en);
    await first;
    await second;

    expect(repository.calls, 1);
    expect(repository.lastLocale, AppLocale.pt);
  });
}
