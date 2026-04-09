import '../domain/models/user_model.dart';

final List<User> mockUsers = [
  User(
    id: '1',
    name: 'Sophie',
    age: 26,
    rating: 4.9,
    imageUrl: 'assets/home.png',
    teaching: const Skill(
      name: 'Photography',
      category: 'Arts',
    ),
    learning: const Skill(name: 'French Cooking', category: 'Cooking'),
    bio: 'The lighting on those shots is per...',
  ),
  User(
    id: '2',
    name: 'Alex',
    age: 28,
    rating: 4.7,
    imageUrl: 'assets/home.png',
    teaching: const Skill(name: 'Design', category: 'Design'),
    learning: const Skill(name: 'Guitar Basics', category: 'Music'),
    bio: 'Product designer focusing on clean aesthetics.',
  ),
  User(
    id: '3',
    name: 'Emma',
    age: 24,
    rating: 4.8,
    imageUrl: 'assets/home.png',
    teaching: const Skill(name: 'Yoga & Meditation', category: 'Wellness'),
    learning: const Skill(name: 'Photography', category: 'Arts'),
    bio: 'Helping others find balance.',
  ),
  User(
    id: '4',
    name: 'Marcus',
    age: 30,
    rating: 5.0,
    imageUrl: 'assets/home.png',
    teaching: const Skill(
      name: 'UI Design',
      category: 'Design',
      type: 'teach',
      level: 'Expert',
    ),
    learning: const Skill(
      name: 'Python',
      category: 'Development',
      type: 'learn',
      level: 'Beginner',
    ),
    bio: 'That portfolio review really helped...',
  ),
  User(
    id: '5',
    name: 'Elena',
    age: 27,
    rating: 4.9,
    imageUrl: 'assets/home.png',
    teaching: const Skill(
      name: 'React.js',
      category: 'Development',
      type: 'teach',
    ),
    learning: const Skill(name: 'German Language', category: 'Languages', type: 'learn'),
    bio: 'Are you free for our React sessio...',
  ),
  User(
    id: '6',
    name: 'Sarah',
    age: 32,
    rating: 4.8,
    imageUrl: 'assets/home.png',
    teaching: const Skill(
      name: 'Italian Cuisine',
      category: 'Cooking',
      type: 'teach',
      level: 'Expert',
    ),
    learning: const Skill(
      name: 'Graphic Design',
      category: 'Design',
      type: 'learn',
      level: 'Intermediate',
    ),
    bio: 'Mastering the art of sourdough.',
  ),
  User(
    id: '7',
    name: 'Jordan',
    age: 29,
    rating: 4.9,
    imageUrl: 'assets/home.png',
    teaching: const Skill(name: 'Python', category: 'Development', type: 'teach'),
    learning: const Skill(name: 'Spanish', category: 'Languages', type: 'learn'),
    bio: 'Python expert ready to swap.',
  ),
  User(
    id: '8',
    name: 'Taylor',
    age: 25,
    rating: 4.8,
    imageUrl: 'assets/home.png',
    teaching: const Skill(name: 'Piano', category: 'Music', type: 'teach'),
    learning: const Skill(name: 'Cooking', category: 'Cooking', type: 'learn'),
    bio: 'Teaching classical piano.',
  ),
  User(
    id: '9',
    name: 'Morgan',
    age: 31,
    rating: 4.7,
    imageUrl: 'assets/home.png',
    teaching: const Skill(name: 'Marketing', category: 'Business'),
    learning: const Skill(name: 'Design', category: 'Design'),
    bio: 'Growth marketing specialist.',
  ),
  User(
    id: '10',
    name: 'Sam',
    age: 28,
    rating: 4.6,
    imageUrl: 'assets/home.png',
    teaching: const Skill(name: 'Copywriting', category: 'Writing'),
    learning: const Skill(name: 'SEO', category: 'Business'),
    bio: 'Sent an image',
  ),
];

final List<User> newMatches = [
  mockUsers[1], // Alex
  mockUsers[6], // Jordan
  mockUsers[7], // Taylor
  mockUsers[8], // Morgan
];

final List<Conversation> mockConversations = [
  Conversation(
    user: mockUsers[3], // Marcus
    lastMessage: 'That portfolio review really helped...',
    timestamp: '2m ago',
    isOnline: true,
    skillTag: 'VISUAL DESIGN',
  ),
  Conversation(
    user: mockUsers[4], // Elena
    lastMessage: 'Are you free for our React sessio...',
    timestamp: '1h ago',
    hasUnread: true,
    skillTag: 'REACT.JS',
  ),
  Conversation(
    user: mockUsers[9], // Sam
    lastMessage: 'Sent an image',
    timestamp: 'Yesterday',
    skillTag: 'COPYWRITING',
  ),
  Conversation(
    user: mockUsers[0], // Sophie
    lastMessage: 'The lighting on those shots is per...',
    timestamp: 'Oct 24',
    skillTag: 'PHOTOGRAPHY',
  ),
];
