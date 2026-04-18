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

class PortfolioItem extends Equatable {
  final String title;
  final String description;
  final String? imageUrl;
  final String? githubUrl;

  const PortfolioItem({
    required this.title,
    required this.description,
    this.imageUrl,
    this.githubUrl,
  });

  factory PortfolioItem.fromMap(Map<String, dynamic> map) {
    return PortfolioItem(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['image_url'],
      githubUrl: map['github_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'github_url': githubUrl,
    };
  }

  @override
  List<Object?> get props => [title, description, imageUrl, githubUrl];
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
  final List<PortfolioItem> portfolio;
  final String? matchId;
  final String? matchStatus;
  final String? matchPayerId;
  final String? primaryCategory;
  final String? expertiseLevel;

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
    this.portfolio = const [],
    this.matchId,
    this.matchStatus,
    this.matchPayerId,
    this.primaryCategory,
    this.expertiseLevel,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    final List<dynamic> skillsData = map['skills'] ?? [];
    final List<Skill> skills = skillsData.map((s) => Skill.fromMap(s)).toList();

    final List<dynamic> portfolioData = map['portfolio'] ?? [];
    final List<PortfolioItem> portfolio =
        portfolioData.map((p) => PortfolioItem.fromMap(p)).toList();
    
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
      bio: map['bio'] ?? '',
      location: map['location'] ?? '',
      profession: map['profession'] ?? 'Skill Swapper',
      portfolio: portfolio,
      matchId: map['match_id'],
      matchStatus: map['match_status'],
      matchPayerId: map['match_payer_id'],
      primaryCategory: map['primary_category'],
      expertiseLevel: map['expertise_level'] ?? 'beginner',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'rating': rating,
      'profile_image': imageUrl,
      'bio': bio,
      'location': location,
      'profession': profession,
      'skills': allSkills.map((s) => s.toMap()).toList(),
      'portfolio': portfolio.map((p) => p.toMap()).toList(),
      'primary_category': primaryCategory,
      'expertise_level': expertiseLevel,
      'match_id': matchId,
      'match_status': matchStatus,
      'match_payer_id': matchPayerId,
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
    portfolio,
    matchId,
    matchStatus,
    matchPayerId,
    primaryCategory,
    expertiseLevel,
  ];
}

class Conversation extends Equatable {
  final User user;
  final String? lastMessage;
  final String? lastMessageTime;
  final bool hasUnread;
  final String? matchId;
  final String status;
  final String? payerId;

  const Conversation({
    required this.user,
    this.lastMessage,
    this.lastMessageTime,
    this.hasUnread = false,
    this.matchId,
    this.status = 'mutual',
    this.payerId,
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
      status: map['status'] ?? 'mutual',
      payerId: map['payer_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': user.toMap(),
      if (lastMessage != null) 'last_message': {
        'content': lastMessage,
        'timestamp': lastMessageTime,
      },
      'has_unread': hasUnread,
      'match_id': matchId,
      'status': status,
      'payer_id': payerId,
    };
  }

  @override
  List<Object?> get props => [user, lastMessage, lastMessageTime, hasUnread, matchId, status, payerId];
}
