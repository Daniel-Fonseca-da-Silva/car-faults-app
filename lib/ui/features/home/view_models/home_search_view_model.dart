import 'package:flutter/foundation.dart';

import '../../../../data/repositories/lookup_repository.dart';
import '../../../../domain/models/app_locale.dart';
import '../home_search_options.dart';

/// Owns the home vehicle-search form and its submission to
/// [LookupRepository].
class HomeSearchViewModel extends ChangeNotifier {
  HomeSearchViewModel({required this.repository});

  final LookupRepository repository;

  /// Sent as `engine` for electric vehicles, which have none to enter —
  /// same sentinel and rule as the web app's `VehicleSearchForm`
  /// (`ELECTRIC_ENGINE_SENTINEL`).
  static const electricEngineSentinel = 'electric';

  String? _brand;
  String? _model;
  int? _year;
  String? _engine;
  FuelOption? _fuel;
  int? _doors;
  bool _isSearching = false;
  LookupSearchResult? _lastResult;

  String? get brand => _brand;
  String? get model => _model;
  int? get year => _year;
  String? get engine => _engine;
  FuelOption? get fuel => _fuel;
  int? get doors => _doors;
  bool get isSearching => _isSearching;

  /// Outcome of the last [search] call, consumed once by the View (which
  /// calls [acknowledgeResult] after handling it) to navigate to the
  /// results screen or show an error.
  LookupSearchResult? get lastResult => _lastResult;

  /// `car-faults-api`'s `LookupQueryDto` requires brand, model, year, engine
  /// and fuel type; only doors is optional. Engine is skipped for electric
  /// vehicles — see [electricEngineSentinel].
  bool get canSubmit {
    return _hasText(_brand) &&
        _hasText(_model) &&
        _year != null &&
        (_fuel == FuelOption.electric || _hasText(_engine)) &&
        _fuel != null;
  }

  void setBrand(String value) => _setField(() => _brand = value);
  void setModel(String value) => _setField(() => _model = value);
  void setYear(int? value) => _setField(() => _year = value);
  void setEngine(String value) => _setField(() => _engine = value);

  /// Clears any typed engine when switching to electric — the field is then
  /// hidden, and a stale value would otherwise be silently resubmitted if
  /// the user later switches back to a fuel that shows it again empty.
  void setFuel(FuelOption? value) => _setField(() {
    _fuel = value;
    if (value == FuelOption.electric) _engine = null;
  });
  void setDoors(int? value) => _setField(() => _doors = value);

  Future<void> search({required AppLocale locale}) async {
    if (!canSubmit || _isSearching) return;

    _isSearching = true;
    _lastResult = null;
    notifyListeners();

    final engine = _fuel == FuelOption.electric
        ? electricEngineSentinel
        : _engine!;

    final result = await repository.search(
      brand: _brand!,
      model: _model!,
      year: _year!,
      engine: engine,
      fuel: _fuel!,
      doors: _doors,
      locale: locale,
    );

    _isSearching = false;
    _lastResult = result;
    notifyListeners();
  }

  /// Clears [lastResult] once the View has shown it, so a rebuild doesn't
  /// handle the same result again.
  void acknowledgeResult() {
    _lastResult = null;
  }

  void _setField(VoidCallback update) {
    update();
    notifyListeners();
  }

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
