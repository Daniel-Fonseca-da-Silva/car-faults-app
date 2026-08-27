import '../../domain/models/app_locale.dart';
import '../services/locale_preferences_service.dart';

/// Loads and persists the user's chosen [AppLocale].
class LocaleRepository {
  LocaleRepository({required LocalePreferencesService service})
    // ignore: prefer_initializing_formals
    : _service = service;

  final LocalePreferencesService _service;

  Future<AppLocale> load() async {
    final languageCode = await _service.readLanguageCode();
    return appLocaleFromLanguageCode(languageCode);
  }

  Future<void> save(AppLocale locale) {
    return _service.writeLanguageCode(locale.languageCode);
  }
}
