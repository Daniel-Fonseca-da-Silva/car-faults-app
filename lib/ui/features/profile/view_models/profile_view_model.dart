import 'package:flutter/foundation.dart';

import '../../../../data/mappers/lookup_mapper.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/lookup_repository.dart';
import '../../../../data/repositories/profile_repository.dart';
import '../../../../domain/models/app_locale.dart';
import '../../../../domain/models/profile_snapshot.dart';
import '../../../../domain/models/saved_vehicle.dart';
import '../../home/home_search_options.dart';

/// Owns the profile snapshot loaded from [ProfileRepository], the
/// account-deletion command triggered from the danger zone, and opening a
/// saved vehicle's real known issues via [LookupRepository].
///
/// [locale] is fixed for the ViewModel's lifetime (a fresh instance is
/// created each time the profile screen opens) and drives both the
/// known-issues language sent to [ProfileRepository] and the vehicle
/// re-lookup in [openVehicle].
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({
    required this.authRepository,
    required this.locale,
    ProfileRepository? repository,
    LookupRepository? lookupRepository,
  }) : _repository = repository ?? ProfileRepository(),
       _lookupRepository = lookupRepository ?? LookupRepository();

  final AuthRepository authRepository;
  final AppLocale locale;
  final ProfileRepository _repository;
  final LookupRepository _lookupRepository;

  ProfileSnapshot? _snapshot;
  ProfileSnapshot? get snapshot => _snapshot;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  DeleteAccountResult? _lastResult;
  DeleteAccountResult? get lastResult => _lastResult;

  /// `GET /v1/users/me` + `GET /v1/users/me/stats` + `GET /v1/user-vehicles`,
  /// combined by [ProfileRepository]. Keeps whatever [snapshot] is already
  /// shown on failure, so a background retry never blanks the screen.
  Future<void> load() async {
    if (_isLoading) return;

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    final snapshot = await _repository.fetchSnapshot(locale: locale);

    _isLoading = false;
    if (snapshot != null) {
      _snapshot = snapshot;
    } else {
      _hasError = true;
    }
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    if (_isDeleting) return;

    _isDeleting = true;
    _lastResult = null;
    notifyListeners();

    final result = await authRepository.deleteAccount();

    _isDeleting = false;
    _lastResult = result;
    notifyListeners();
  }

  /// Clears [lastResult] once the View has shown it, so a rebuild doesn't
  /// show the same SnackBar again.
  void acknowledgeResult() {
    _lastResult = null;
  }

  String? _openingVehicleId;

  bool isOpeningVehicle(String vehicleId) => _openingVehicleId == vehicleId;

  LookupSearchResult? _pendingResult;

  /// Outcome of the last [openVehicle] call, consumed once by the View
  /// (which calls [acknowledgePendingResult] after handling it) to navigate
  /// to the real results screen or show an error.
  LookupSearchResult? get pendingResult => _pendingResult;

  int? _pendingSearchedYear;
  int? get pendingSearchedYear => _pendingSearchedYear;

  /// Looks up [vehicle] via `GET /v1/lookups` so tapping a saved vehicle
  /// opens its real known issues instead of `LookupDemoDisplay`'s fixture
  /// data — [SavedVehicle] carries no reviews/fixes of its own, matching how
  /// [FavoritesViewModel] resolves a saved vehicle.
  Future<void> openVehicle(SavedVehicle vehicle) async {
    if (_openingVehicleId != null) return;

    _openingVehicleId = vehicle.id;
    notifyListeners();

    final fuel =
        (vehicle.fuelType == null
            ? null
            : fuelOptionFromApiValue(vehicle.fuelType!)) ??
        FuelOption.petrol;

    final result = await _lookupRepository.search(
      brand: vehicle.brand,
      model: vehicle.model,
      year: vehicle.yearFrom,
      engine: vehicle.engine,
      fuel: fuel,
      doors: vehicle.doors,
      locale: locale,
    );

    _openingVehicleId = null;
    _pendingResult = result;
    _pendingSearchedYear = vehicle.yearFrom;
    notifyListeners();
  }

  /// Clears [pendingResult] once the View has shown it, so a rebuild doesn't
  /// handle the same result again.
  void acknowledgePendingResult() {
    _pendingResult = null;
  }
}
