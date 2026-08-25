import 'package:car_faults_app/data/repositories/legal_repository.dart';
import 'package:car_faults_app/domain/models/legal_content.dart';
import 'package:flutter/foundation.dart';

/// Which document to scroll to when the legal screen opens.
enum LegalSectionTarget { privacy, terms }

/// Loads [LegalContent] for the active language and exposes UI state.
class LegalViewModel extends ChangeNotifier {
  LegalViewModel({required LegalRepository repository})
    : _repository = repository; // ignore: prefer_initializing_formals

  final LegalRepository _repository;

  bool _isLoading = false;
  LegalContent? _content;
  String? _errorMessage;
  String? _loadedLanguageCode;

  bool get isLoading => _isLoading;
  LegalContent? get content => _content;
  String? get errorMessage => _errorMessage;

  Future<void> load(String languageCode) async {
    if (_isLoading) return;
    if (_content != null && _loadedLanguageCode == languageCode) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _content = await _repository.load(languageCode);
      _loadedLanguageCode = languageCode;
    } catch (_) {
      _content = null;
      _loadedLanguageCode = null;
      _errorMessage = 'load_failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the cached language so the next [load] always reloads.
  Future<void> reload(String languageCode) async {
    _loadedLanguageCode = null;
    await load(languageCode);
  }
}
