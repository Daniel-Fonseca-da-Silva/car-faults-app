/// One numbered section of a legal document (privacy policy or terms).
class LegalSection {
  const LegalSection({
    required this.id,
    required this.heading,
    required this.paragraphs,
  });

  final String id;
  final String heading;
  final List<String> paragraphs;
}

/// A full legal document: title, dates and ordered sections.
class LegalDocument {
  const LegalDocument({
    required this.title,
    required this.effectiveDate,
    required this.lastUpdated,
    required this.sections,
  });

  final String title;
  final String effectiveDate;
  final String lastUpdated;
  final List<LegalSection> sections;
}

/// Everything the legal screen needs from a locale's privacy.json.
class LegalContent {
  const LegalContent({
    required this.heroEyebrow,
    required this.heroTitle,
    required this.heroImageAlt,
    required this.navPrivacy,
    required this.navTerms,
    required this.policy,
    required this.terms,
  });

  final String heroEyebrow;
  final String heroTitle;
  final String heroImageAlt;
  final String navPrivacy;
  final String navTerms;
  final LegalDocument policy;
  final LegalDocument terms;
}
