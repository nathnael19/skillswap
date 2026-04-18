/// Single source of truth for all skill categories and expertise levels.
/// These should ideally be fetched from the /config API but are defined
/// here as unified fallbacks.
class AppCategories {
  static const List<String> categories = [
    'Design',
    'Development',
    'Marketing',
    'Writing',
    'Business',
    'Data Science',
    'Python',
    'Cooking'
  ];

  static const List<String> expertiseLevels = [
    'All',
    'Beginner',
    'Intermediate',
    'Expert'
  ];
}
