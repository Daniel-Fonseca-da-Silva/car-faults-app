import 'package:flutter/foundation.dart';

import '../../../../data/mappers/lookup_mapper.dart';
import '../../../../data/repositories/lookup_repository.dart';
import '../../../../data/repositories/platform_repository.dart';
import '../../../../domain/models/app_locale.dart';
import '../../../../domain/models/top_fault.dart';
import '../../home/home_search_options.dart';

/// Loads the full, cursor-paginated most-reported-faults ranking for the
/// "Defeitos" screen, and opens one of them via [LookupRepository] — the
/// full-screen counterpart to [HomeTopFaultsViewModel]'s fixed teaser.
class DefectsViewModel extends ChangeNotifier {
  DefectsViewModel({
    required this.repository,
    LookupRepository? lookupRepository,
  }) : _lookupRepository = lookupRepository ?? LookupRepository();

  static const _pageSize = 20;

  final PlatformRepository repository;
  final LookupRepository _lookupRepository;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  bool _hasMoreError = false;
  List<TopFault> _faults = const [];
  String? _nextCursor;
  AppLocale? _loadedLocale;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasError => _hasError;
  bool get hasMoreError => _hasMoreError;
  List<TopFault> get faults => _faults;
  bool get hasMore => _nextCursor != null;

  /// No-ops if [locale] is already loaded (or currently loading) and the
  /// last load succeeded, so a rebuild after a locale-independent state
  /// change doesn't refetch.
  Future<void> load(AppLocale locale) async {
    if (_isLoading) return;
    if (_loadedLocale == locale && !_hasError) return;

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final page = await repository.getTopFaultsPage(
        locale: locale,
        limit: _pageSize,
      );
      _faults = page.items;
      _nextCursor = page.nextCursor;
      _loadedLocale = locale;
    } catch (_) {
      _hasError = true;
      _loadedLocale = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Appends the next page. No-ops while a load is already in flight or
  /// there is no further page.
  Future<void> loadMore() async {
    final locale = _loadedLocale;
    if (locale == null || _isLoading || _isLoadingMore || !hasMore) return;

    _isLoadingMore = true;
    _hasMoreError = false;
    notifyListeners();

    try {
      final page = await repository.getTopFaultsPage(
        locale: locale,
        limit: _pageSize,
        cursor: _nextCursor,
      );
      _faults = [..._faults, ...page.items];
      _nextCursor = page.nextCursor;
    } catch (_) {
      _hasMoreError = true;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  String? _openingFaultId;

  bool isOpeningFault(String faultId) => _openingFaultId == faultId;

  LookupSearchResult? _pendingResult;

  /// Outcome of the last [openVehicle] call, consumed once by the View
  /// (which calls [acknowledgePendingResult] after handling it) to
  /// navigate to the results screen or show an error.
  LookupSearchResult? get pendingResult => _pendingResult;

  /// Looks up [fault]'s vehicle via `GET /v1/lookups`, keyed by its
  /// brand/model/yearFrom/engine/fuel type/doors — same call the home
  /// screen's search and favorites use. Falls back to [FuelOption.petrol]
  /// when the fault carries no fuel type (the vehicle model has none on
  /// record — common, since it's an optional column), same as
  /// `FavoritesViewModel.openVehicle`. [engine] is always present per
  /// `TopFaultVehicleDto`, but is checked defensively since the field is
  /// nullable in [TopFault].
  Future<void> openVehicle(TopFault fault, {required AppLocale locale}) async {
    final engine = fault.vehicleEngine;
    if (engine == null) return;
    if (_openingFaultId != null) return;

    final fuelType = fault.vehicleFuelType;
    final fuel =
        (fuelType == null ? null : fuelOptionFromApiValue(fuelType)) ??
        FuelOption.petrol;

    _openingFaultId = fault.id;
    notifyListeners();

    final result = await _lookupRepository.search(
      brand: fault.vehicleBrand,
      model: fault.vehicleModel,
      year: fault.vehicleYearFrom,
      engine: engine,
      fuel: fuel,
      doors: fault.vehicleDoors,
      locale: locale,
    );

    _openingFaultId = null;
    _pendingResult = result;
    notifyListeners();
  }

  /// Clears [pendingResult] once the View has shown it, so a rebuild
  /// doesn't handle the same result again.
  void acknowledgePendingResult() {
    _pendingResult = null;
  }
}
