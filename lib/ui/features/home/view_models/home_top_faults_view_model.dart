import 'package:flutter/foundation.dart';

import '../../../../data/mappers/lookup_mapper.dart';
import '../../../../data/repositories/lookup_repository.dart';
import '../../../../data/repositories/platform_repository.dart';
import '../../../../domain/models/app_locale.dart';
import '../../../../domain/models/top_fault.dart';
import '../home_search_options.dart';

/// Loads the most-reported faults for the home screen, for the active
/// locale, and opens one of them via [LookupRepository].
class HomeTopFaultsViewModel extends ChangeNotifier {
  HomeTopFaultsViewModel({
    required this.repository,
    LookupRepository? lookupRepository,
  }) : _lookupRepository = lookupRepository ?? LookupRepository();

  final PlatformRepository repository;
  final LookupRepository _lookupRepository;

  bool _isLoading = false;
  List<TopFault> _faults = const [];
  bool _hasError = false;
  AppLocale? _loadedLocale;

  bool get isLoading => _isLoading;
  List<TopFault> get faults => _faults;
  bool get hasError => _hasError;

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
      _faults = await repository.getTopFaults(locale: locale);
      _loadedLocale = locale;
    } catch (_) {
      _hasError = true;
      _loadedLocale = null;
    } finally {
      _isLoading = false;
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

  /// Looks up [fault]'s vehicle via `GET /v1/lookups` — same behavior as
  /// `DefectsViewModel.openVehicle`, including the [FuelOption.petrol]
  /// fallback when the fault carries no fuel type.
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
