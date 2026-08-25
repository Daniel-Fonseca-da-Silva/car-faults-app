import 'dart:convert';

import 'package:flutter/services.dart';

import '../../ui/core/constants/app_assets.dart';

/// Loads the raw privacy/terms JSON from the asset bundle.
///
/// Accepts an [AssetBundle] so tests can inject a fake without touching disk.
class LegalDocumentService {
  LegalDocumentService({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  Future<Map<String, dynamic>> load(String languageCode) async {
    final path = AppAssets.legalDocument(languageCode);
    final raw = await _bundle.loadString(path);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Legal document root must be a JSON object.');
    }
    return decoded;
  }
}
