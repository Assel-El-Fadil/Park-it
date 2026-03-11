class LegalDocument {
  final String title;
  final String lastUpdated;
  final List<Section> sections;

  LegalDocument({
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });
}

class Section {
  final String title;
  final String content;
  final List<String>? bulletPoints;

  Section({required this.title, required this.content, this.bulletPoints});
}
