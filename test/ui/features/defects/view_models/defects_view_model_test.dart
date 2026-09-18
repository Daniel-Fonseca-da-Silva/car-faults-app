import 'package:car_faults_app/data/repositories/lookup_repository.dart';
import 'package:car_faults_app/data/repositories/platform_repository.dart';
import 'package:car_faults_app/domain/models/app_locale.dart';
import 'package:car_faults_app/domain/models/issue_severity.dart';
import 'package:car_faults_app/domain/models/top_fault.dart';
import 'package:car_faults_app/domain/models/top_faults_page.dart';
import 'package:car_faults_app/ui/features/defects/view_models/defects_view_model.dart';
import 'package:car_faults_app/ui/features/home/home_search_options.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePlatformRepository extends PlatformRepository {
  _FakePlatformRepository({this.pages, this.error});

  List<TopFaultsPage>? pages;
  Object? error;
  var calls = 0;
  final lastCursors = <String?>[];
  AppLocale? lastLocale;

  @override
  Future<TopFaultsPage> getTopFaultsPage({
    required AppLocale locale,
    int limit = 20,
    String? cursor,
  }) async {
    lastLocale = locale;
    lastCursors.add(cursor);
    final index = calls;
    calls++;
    if (error != null) throw error!;
    return pages![index];
  }
}

class _FakeLookupRepository extends LookupRepository {
  _FakeLookupRepository({this.result});

  LookupSearchResult? result;
  var searchCalls = <Map<String, dynamic>>[];

  @override
  Future<LookupSearchResult> search({
    required String brand,
    required String model,
    required int year,
    required String engine,
    required FuelOption fuel,
    int? doors,
    required AppLocale locale,
  }) async {
    searchCalls.add({
      'brand': brand,
      'model': model,
      'year': year,
      'engine': engine,
      'fuel': fuel,
      'doors': doors,
      'locale': locale,
    });
    return result!;
  }
}

const _fault1 = TopFault(
  id: 'f1',
  title: 'Oil leak',
  severity: IssueSeverity.medium,
  reportCount: 12,
  vehicleBrand: 'BMW',
  vehicleModel: '320d',
  vehicleYearFrom: 2012,
  vehicleEngine: '2.0d',
  vehicleFuelType: 'diesel',
  vehicleDoors: 4,
);

const _fault2 = TopFault(
  id: 'f2',
  title: 'Turbo failure',
  severity: IssueSeverity.high,
  reportCount: 30,
  vehicleBrand: 'Audi',
  vehicleModel: 'A4',
  vehicleYearFrom: 2014,
  vehicleEngine: '2.0 TFSI',
);

const _faultNoEngine = TopFault(
  id: 'f3',
  title: 'Suspension noise',
  severity: IssueSeverity.low,
  reportCount: 8,
  vehicleBrand: 'Renault',
  vehicleModel: 'Clio',
  vehicleYearFrom: 2010,
);

void main() {
  group('load', () {
    test('sets the first page and hasMore from nextCursor', () async {
      final repository = _FakePlatformRepository(
        pages: const [
          TopFaultsPage(items: [_fault1], nextCursor: 'cursor-2'),
        ],
      );
      final viewModel = DefectsViewModel(repository: repository);

      await viewModel.load(AppLocale.pt);

      expect(viewModel.faults, [_fault1]);
      expect(viewModel.hasMore, isTrue);
      expect(viewModel.hasError, isFalse);
      expect(repository.lastLocale, AppLocale.pt);
      expect(repository.lastCursors, [null]);
    });

    test('hasMore is false when the page has no nextCursor', () async {
      final repository = _FakePlatformRepository(
        pages: const [
          TopFaultsPage(items: [_fault1], nextCursor: null),
        ],
      );
      final viewModel = DefectsViewModel(repository: repository);

      await viewModel.load(AppLocale.pt);

      expect(viewModel.hasMore, isFalse);
    });

    test('sets hasError when the repository throws', () async {
      final viewModel = DefectsViewModel(
        repository: _FakePlatformRepository(error: Exception('offline')),
      );

      await viewModel.load(AppLocale.en);

      expect(viewModel.hasError, isTrue);
      expect(viewModel.faults, isEmpty);
    });

    test('skips a refetch for the same locale after success', () async {
      final repository = _FakePlatformRepository(
        pages: const [
          TopFaultsPage(items: [_fault1], nextCursor: null),
        ],
      );
      final viewModel = DefectsViewModel(repository: repository);

      await viewModel.load(AppLocale.pt);
      await viewModel.load(AppLocale.pt);

      expect(repository.calls, 1);
    });
  });

  group('loadMore', () {
    test('appends the next page using the stored cursor', () async {
      final repository = _FakePlatformRepository(
        pages: const [
          TopFaultsPage(items: [_fault1], nextCursor: 'cursor-2'),
          TopFaultsPage(items: [_fault2], nextCursor: null),
        ],
      );
      final viewModel = DefectsViewModel(repository: repository);
      await viewModel.load(AppLocale.pt);

      await viewModel.loadMore();

      expect(viewModel.faults, [_fault1, _fault2]);
      expect(viewModel.hasMore, isFalse);
      expect(repository.lastCursors, [null, 'cursor-2']);
    });

    test('no-ops when there is no next page', () async {
      final repository = _FakePlatformRepository(
        pages: const [
          TopFaultsPage(items: [_fault1], nextCursor: null),
        ],
      );
      final viewModel = DefectsViewModel(repository: repository);
      await viewModel.load(AppLocale.pt);

      await viewModel.loadMore();

      expect(repository.calls, 1);
      expect(viewModel.faults, [_fault1]);
    });

    test('sets hasMoreError without dropping already-loaded faults', () async {
      final repository = _FakePlatformRepository(
        pages: const [
          TopFaultsPage(items: [_fault1], nextCursor: 'cursor-2'),
        ],
      );
      final viewModel = DefectsViewModel(repository: repository);
      await viewModel.load(AppLocale.pt);
      repository.error = Exception('offline');

      await viewModel.loadMore();

      expect(viewModel.hasMoreError, isTrue);
      expect(viewModel.faults, [_fault1]);
      expect(viewModel.hasMore, isTrue);
    });
  });

  group('openVehicle', () {
    test('looks up the vehicle when a fuel type is on record', () async {
      final lookupRepository = _FakeLookupRepository(
        result: const LookupSearchFailure(LookupFailureReason.network),
      );
      final viewModel = DefectsViewModel(
        repository: _FakePlatformRepository(),
        lookupRepository: lookupRepository,
      );

      await viewModel.openVehicle(_fault1, locale: AppLocale.pt);

      expect(lookupRepository.searchCalls, hasLength(1));
      final call = lookupRepository.searchCalls.single;
      expect(call['brand'], 'BMW');
      expect(call['model'], '320d');
      expect(call['year'], 2012);
      expect(call['engine'], '2.0d');
      expect(call['fuel'], FuelOption.diesel);
      expect(call['doors'], 4);
    });

    test(
      'falls back to FuelOption.petrol when the fault has no fuel type '
      'on record',
      () async {
        final lookupRepository = _FakeLookupRepository(
          result: const LookupSearchFailure(LookupFailureReason.network),
        );
        final viewModel = DefectsViewModel(
          repository: _FakePlatformRepository(),
          lookupRepository: lookupRepository,
        );

        await viewModel.openVehicle(_fault2, locale: AppLocale.pt);

        expect(lookupRepository.searchCalls, hasLength(1));
        expect(lookupRepository.searchCalls.single['fuel'], FuelOption.petrol);
      },
    );

    test('no-ops when the fault has no engine on record', () async {
      final lookupRepository = _FakeLookupRepository();
      final viewModel = DefectsViewModel(
        repository: _FakePlatformRepository(),
        lookupRepository: lookupRepository,
      );

      await viewModel.openVehicle(_faultNoEngine, locale: AppLocale.pt);

      expect(lookupRepository.searchCalls, isEmpty);
      expect(viewModel.pendingResult, isNull);
    });

    test('acknowledgePendingResult clears pendingResult', () async {
      const failure = LookupSearchFailure(LookupFailureReason.network);
      final lookupRepository = _FakeLookupRepository(result: failure);
      final viewModel = DefectsViewModel(
        repository: _FakePlatformRepository(),
        lookupRepository: lookupRepository,
      );
      await viewModel.openVehicle(_fault1, locale: AppLocale.pt);

      viewModel.acknowledgePendingResult();

      expect(viewModel.pendingResult, isNull);
    });
  });
}
