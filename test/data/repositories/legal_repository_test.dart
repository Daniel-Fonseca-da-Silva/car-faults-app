import 'dart:convert';

import 'package:car_faults_app/data/repositories/legal_repository.dart';
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

const _fixture = '''
{
  "hero": {
    "eyebrow": "Legal",
    "title": "Privacy and Terms",
    "imageAlt": "Fiat docs"
  },
  "nav": {
    "privacy": "Privacy Policy",
    "terms": "Terms of Service"
  },
  "policy": {
    "title": "Privacy Policy",
    "effectiveDate": "Effective: 14 Aug 2026",
    "lastUpdated": "Updated: 14 Aug 2026",
    "sections": {
      "scope": {
        "heading": "1. Scope",
        "body": "First paragraph.\\n\\nSecond paragraph."
      },
      "controller": {
        "heading": "2. Controller",
        "body": "Controller only."
      }
    }
  },
  "terms": {
    "title": "Terms of Service",
    "effectiveDate": "Effective: 14 Aug 2026",
    "lastUpdated": "Updated: 14 Aug 2026",
    "sections": {
      "provider": {
        "heading": "1. Provider",
        "body": "Provider paragraph."
      }
    }
  }
}
''';

void main() {
  test('parses hero, nav, documents and splits paragraphs', () async {
    final bundle = _FakeAssetBundle({AppAssets.legalDocument('en'): _fixture});
    final repository = LegalRepository(
      service: LegalDocumentService(bundle: bundle),
    );

    final content = await repository.load('en');

    expect(content.heroEyebrow, 'Legal');
    expect(content.heroTitle, 'Privacy and Terms');
    expect(content.navPrivacy, 'Privacy Policy');
    expect(content.navTerms, 'Terms of Service');
    expect(content.policy.title, 'Privacy Policy');
    expect(content.policy.sections, hasLength(2));
    expect(content.policy.sections.first.id, 'scope');
    expect(content.policy.sections.first.paragraphs, [
      'First paragraph.',
      'Second paragraph.',
    ]);
    expect(content.terms.sections.single.id, 'provider');
  });

  test('preserves section insertion order from the JSON object', () async {
    final bundle = _FakeAssetBundle({AppAssets.legalDocument('pt'): _fixture});
    final repository = LegalRepository(
      service: LegalDocumentService(bundle: bundle),
    );

    final content = await repository.load('pt');

    expect(content.policy.sections.map((section) => section.id).toList(), [
      'scope',
      'controller',
    ]);
  });

  test('throws FormatException when a required field is missing', () async {
    final bundle = _FakeAssetBundle({
      AppAssets.legalDocument('en'): '{"hero": {}}',
    });
    final repository = LegalRepository(
      service: LegalDocumentService(bundle: bundle),
    );

    expect(() => repository.load('en'), throwsA(isA<FormatException>()));
  });
}
