import 'package:flutter/foundation.dart';

import '../../../../data/repositories/platform_repository.dart';
import '../../../../domain/models/platform_stats.dart';

/// Loads live platform-wide stats for the home stats bar.
class HomeStatsViewModel extends ChangeNotifier {
  HomeStatsViewModel({required this.repository});

  final PlatformRepository repository;

  bool _isLoading = false;
  PlatformStats? _stats;
  bool _hasError = false;

  bool get isLoading => _isLoading;
  PlatformStats? get stats => _stats;
  bool get hasError => _hasError;

  Future<void> load() async {
    if (_isLoading) return;

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      _stats = await repository.getStats();
    } catch (_) {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
