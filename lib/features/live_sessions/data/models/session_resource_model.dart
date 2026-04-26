class SessionResource {
  final String id;
  final String type;
  final String title;
  final String? description;
  final String? url;
  final String? snippetText;
  final String createdBy;
  final DateTime createdAt;

  const SessionResource({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.url,
    required this.snippetText,
    required this.createdBy,
    required this.createdAt,
  });

  factory SessionResource.fromMap(Map<String, dynamic> map) {
    return SessionResource(
      id: map['id']?.toString() ?? '',
      type: map['type']?.toString() ?? 'link',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString(),
      url: map['url']?.toString(),
      snippetText: map['snippet_text']?.toString(),
      createdBy: map['created_by']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
