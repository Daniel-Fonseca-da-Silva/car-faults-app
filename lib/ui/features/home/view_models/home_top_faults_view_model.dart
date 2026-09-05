import 'package:flutter/foundation.dart';

import '../../../../data/repositories/platform_repository.dart';
import '../../../../domain/models/app_locale.dart';
import '../../../../domain/models/top_fault.dart';

/// Loads the most-reported faults for the home screen, for the active
/// locale.
class HomeTopFaultsViewModel extends ChangeNotifier {
  HomeTopFaultsViewModel({required this.repository});

  final PlatformRepository repository;

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
}
