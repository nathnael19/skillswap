import 'package:equatable/equatable.dart';

class Skill extends Equatable {
  final String name;
  final String category;
  final String type; // 'teach' or 'learn'
  final String level;

  const Skill({
    required this.name,
    required this.category,
    this.type = 'teach',
    this.level = 'beginner',
  });

  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      type: map['type'] ?? 'teach',
      level: map['level'] ?? 'beginner',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'type': type,
      'level': level,
    };
  }

  @override
  List<Object?> get props => [name, category, type, level];
}

class User extends Equatable {
  final String id;
  final String name;
  final int age;
  final double rating;
  final String imageUrl;
  final Skill? teaching;
  final Skill? learning;
  final List<Skill> allSkills;
  final String bio;
  final String location;
  final String profession;
  final String? matchId;

  const User({
    required this.id,
    required this.name,
    this.age = 0,
    this.rating = 0.0,
    required this.imageUrl,
    this.teaching,
    this.learning,
    this.allSkills = const [],
    this.bio = '',
    this.location = '',
    this.profession = '',
    this.matchId,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    final List<dynamic> skillsData = map['skills'] ?? [];
    final List<Skill> skills = skillsData.map((s) => Skill.fromMap(s)).toList();
    
    Skill? teachingSkill;
    Skill? learningSkill;
    
    try {
      teachingSkill = skills.firstWhere((s) => s.type == 'teach');
    } catch (_) {}
    
    try {
      learningSkill = skills.firstWhere((s) => s.type == 'learn');
    } catch (_) {}

    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      imageUrl: map['profile_image'] ?? 'assets/home.png',
      teaching: teachingSkill,
      learning: learningSkill,
      allSkills: skills,
      profession: map['profession'] ?? 'Skill Swapper',
      matchId: map['match_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'rating': rating,
      'profile_image': imageUrl,
      'bio': bio,
      'location': location,
      'profession': profession,
      'skills': allSkills.map((s) => s.toMap()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    age,
    rating,
    imageUrl,
    teaching,
    learning,
    allSkills,
    bio,
    location,
    profession,
    matchId,
  ];
}

class Conversation extends Equatable {
  final User user;
  final String? lastMessage;
  final String? lastMessageTime;
  final bool hasUnread;
  final String? matchId;

  const Conversation({
    required this.user,
    this.lastMessage,
    this.lastMessageTime,
    this.hasUnread = false,
    this.matchId,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
    final userMap = Map<String, dynamic>.from(map['user']);
    userMap['match_id'] = map['match_id'];
    
    final lastMsgData = map['last_message'];
    
    return Conversation(
      user: User.fromMap(userMap),
      lastMessage: lastMsgData != null ? lastMsgData['content'] : null,
      lastMessageTime: lastMsgData != null ? lastMsgData['timestamp'] : null,
      hasUnread: map['has_unread'] ?? false,
      matchId: map['match_id'],
    );
  }

  @override
  List<Object?> get props => [user, lastMessage, lastMessageTime, hasUnread, matchId];
}
