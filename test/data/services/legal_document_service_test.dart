import 'dart:convert';

import 'package:car_faults_app/data/services/legal_document_service.dart';
import 'package:car_faults_app/ui/core/constants/app_assets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAssetBundle extends CachingAssetBundle {
  _FakeAssetBundle(this._assets);

  final Map<String, String> _assets;

  @override
  Future<ByteData> load(String key) async {
    final value = _assets[key];
    if (value == null) {
      throw FlutterError('Unable to load asset: $key');
    }
    final bytes = Uint8List.fromList(utf8.encode(value));
    return ByteData.view(bytes.buffer);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('load returns the decoded JSON object for a known language', () async {
    final path = AppAssets.legalDocument('en');
    final bundle = _FakeAssetBundle({path: '{"hero":{"eyebrow":"Legal"}}'});
    final service = LegalDocumentService(bundle: bundle);

    final json = await service.load('en');

    expect(json['hero'], isA<Map<String, dynamic>>());
  });

  test('load falls back to Portuguese for an unknown language code', () async {
    final path = AppAssets.legalDocument('xx');
    expect(path, AppAssets.legalDocument('pt'));

    final bundle = _FakeAssetBundle({path: '{"ok":true}'});
    final service = LegalDocumentService(bundle: bundle);

    final json = await service.load('xx');

    expect(json['ok'], isTrue);
  });

  test('load throws when the root JSON value is not an object', () async {
    final path = AppAssets.legalDocument('en');
    final bundle = _FakeAssetBundle({path: '[]'});
    final service = LegalDocumentService(bundle: bundle);

    expect(() => service.load('en'), throwsA(isA<FormatException>()));
  });

  test('real assets for pt, en and es are registered JSON objects', () async {
    final service = LegalDocumentService();

    for (final code in ['pt', 'en', 'es']) {
      final json = await service.load(code);
      expect(json.containsKey('policy'), isTrue, reason: code);
      expect(json.containsKey('terms'), isTrue, reason: code);
    }
  });
}
