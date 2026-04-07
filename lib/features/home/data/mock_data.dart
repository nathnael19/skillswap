import '../domain/models/user_model.dart';

final List<User> mockUsers = [
  User(
    id: '1',
    name: 'Sophie',
    age: 26,
    rating: 4.9,
    imageUrl: 'assets/home.png',
    teaching: const Skill(
      name: 'Digital Illustration & Figma',
      category: 'Design',
    ),
    learning: const Skill(name: 'French Cooking', category: 'Cooking'),
  ),
  User(
    id: '2',
    name: 'Alex',
    age: 28,
    rating: 4.7,
    imageUrl: 'assets/home.png',
    teaching: const Skill(name: 'Python Programming', category: 'Development'),
    learning: const Skill(name: 'Guitar Basics', category: 'Music'),
  ),
  User(
    id: '3',
    name: 'Emma',
    age: 24,
    rating: 4.8,
    imageUrl: 'assets/home.png',
    teaching: const Skill(name: 'Yoga & Meditation', category: 'Wellness'),
    learning: const Skill(name: 'Photography', category: 'Arts'),
  ),
  User(
    id: '4',
    name: 'Marcus',
    age: 30,
    rating: 4.6,
    imageUrl: 'assets/home.png',
    teaching: const Skill(
      name: 'React Native Development',
      category: 'Development',
    ),
    learning: const Skill(name: 'Italian Cuisine', category: 'Cooking'),
  ),
  User(
    id: '5',
    name: 'Luna',
    age: 25,
    rating: 4.9,
    imageUrl: 'assets/home.png',
    teaching: const Skill(name: 'Watercolor Painting', category: 'Arts'),
    learning: const Skill(name: 'Spanish Language', category: 'Languages'),
  ),
];
