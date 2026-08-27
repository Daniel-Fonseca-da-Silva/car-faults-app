import 'package:shared_preferences/shared_preferences.dart';

/// Reads and writes the persisted language code via [SharedPreferences].
class LocalePreferencesService {
  static const _languageCodeKey = 'locale_language_code';

  Future<String?> readLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageCodeKey);
  }

  Future<void> writeLanguageCode(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, languageCode);
  }
}
