class Hub {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String category;
  final bool isPrivate;
  final bool isMember;
  final int memberCount;

  const Hub({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.category,
    required this.isPrivate,
    required this.isMember,
    required this.memberCount,
  });

  factory Hub.fromMap(Map<String, dynamic> map) {
    return Hub(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      slug: map['slug']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      isPrivate: map['is_private'] == true,
      isMember: map['is_member'] == true,
      memberCount: (map['member_count'] as num?)?.toInt() ?? 0,
    );
  }
}
