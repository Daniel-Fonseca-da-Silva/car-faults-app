import 'package:flutter/foundation.dart';

import '../../../data/repositories/locale_repository.dart';
import '../../../domain/models/app_locale.dart';

/// Holds the active [AppLocale] and persists changes via [LocaleRepository].
class LocaleViewModel extends ChangeNotifier {
  LocaleViewModel({
    required LocaleRepository repository,
    AppLocale initialLocale = AppLocale.pt,
  })
    // ignore: prefer_initializing_formals
    : _repository = repository,
       _locale = initialLocale;

  final LocaleRepository _repository;
  AppLocale _locale;

  AppLocale get locale => _locale;

  Future<void> setLocale(AppLocale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();
    await _repository.save(locale);
  }
}
