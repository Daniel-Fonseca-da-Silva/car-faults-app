import 'package:flutter/foundation.dart';

import '../home_search_options.dart';

/// Owns the home vehicle-search form and the fake search delay before
/// navigation to the mocked results screen.
class HomeSearchViewModel extends ChangeNotifier {
  HomeSearchViewModel({
    this.searchDelay = const Duration(milliseconds: 1200),
    Future<void> Function(Duration duration)? delay,
  }) : _delay = delay ?? Future<void>.delayed;

  final Duration searchDelay;
  final Future<void> Function(Duration duration) _delay;

  String? _brand;
  String? _model;
  int? _year;
  String? _engine;
  FuelOption? _fuel;
  int? _doors;
  bool _isSearching = false;

  String? get brand => _brand;
  String? get model => _model;
  int? get year => _year;
  String? get engine => _engine;
  FuelOption? get fuel => _fuel;
  int? get doors => _doors;
  bool get isSearching => _isSearching;

  bool get canSubmit {
    return _hasText(_brand) ||
        _hasText(_model) ||
        _year != null ||
        _hasText(_engine) ||
        _fuel != null ||
        _doors != null;
  }

  void setBrand(String value) => _setField(() => _brand = value);
  void setModel(String value) => _setField(() => _model = value);
  void setYear(int? value) => _setField(() => _year = value);
  void setEngine(String value) => _setField(() => _engine = value);
  void setFuel(FuelOption? value) => _setField(() => _fuel = value);
  void setDoors(int? value) => _setField(() => _doors = value);

  Future<void> search() async {
    if (!canSubmit || _isSearching) return;

    _isSearching = true;
    notifyListeners();

    await _delay(searchDelay);

    _isSearching = false;
    notifyListeners();
  }

  void _setField(VoidCallback update) {
    update();
    notifyListeners();
  }

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
