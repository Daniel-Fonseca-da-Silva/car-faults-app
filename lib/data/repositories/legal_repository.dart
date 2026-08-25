import '../services/legal_document_service.dart';
import '../../domain/models/legal_content.dart';

/// Transforms the bundled privacy.json into domain [LegalContent].
///
/// Paragraphs are split on blank lines (`\n\n`), matching the web
/// `LegalDocument` component.
class LegalRepository {
  // ignore: prefer_initializing_formals
  LegalRepository({required LegalDocumentService service}) : _service = service;

  final LegalDocumentService _service;

  Future<LegalContent> load(String languageCode) async {
    final json = await _service.load(languageCode);
    return _parseContent(json);
  }

  LegalContent _parseContent(Map<String, dynamic> json) {
    final hero = _asMap(json['hero'], 'hero');
    final nav = _asMap(json['nav'], 'nav');
    final policy = _asMap(json['policy'], 'policy');
    final terms = _asMap(json['terms'], 'terms');

    return LegalContent(
      heroEyebrow: _asString(hero['eyebrow'], 'hero.eyebrow'),
      heroTitle: _asString(hero['title'], 'hero.title'),
      heroImageAlt: _asString(hero['imageAlt'], 'hero.imageAlt'),
      navPrivacy: _asString(nav['privacy'], 'nav.privacy'),
      navTerms: _asString(nav['terms'], 'nav.terms'),
      policy: _parseDocument(policy, 'policy'),
      terms: _parseDocument(terms, 'terms'),
    );
  }

  LegalDocument _parseDocument(Map<String, dynamic> json, String path) {
    final sectionsJson = _asMap(json['sections'], '$path.sections');
    final sections = <LegalSection>[];

    for (final entry in sectionsJson.entries) {
      final sectionMap = _asMap(entry.value, '$path.sections.${entry.key}');
      final body = _asString(
        sectionMap['body'],
        '$path.sections.${entry.key}.body',
      );
      sections.add(
        LegalSection(
          id: entry.key,
          heading: _asString(
            sectionMap['heading'],
            '$path.sections.${entry.key}.heading',
          ),
          paragraphs: _splitParagraphs(body),
        ),
      );
    }

    return LegalDocument(
      title: _asString(json['title'], '$path.title'),
      effectiveDate: _asString(json['effectiveDate'], '$path.effectiveDate'),
      lastUpdated: _asString(json['lastUpdated'], '$path.lastUpdated'),
      sections: sections,
    );
  }

  List<String> _splitParagraphs(String body) {
    return body
        .split('\n\n')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> _asMap(Object? value, String path) {
    if (value is Map<String, dynamic>) return value;
    throw FormatException('Expected object at $path.');
  }

  String _asString(Object? value, String path) {
    if (value is String) return value;
    throw FormatException('Expected string at $path.');
  }
}
