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
  final String email;
  final int age;
  final double rating;
  final int ratingCount;
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
  final List<String> fcmTokens;
  final DateTime? createdAt;
  final int creditsBalanceMinor;
  final bool isOnline;
  final DateTime? lastActive;
  final int teachingSeconds;
  final int learningStreak;
  final int highestLearningStreak;
  final Map<String, dynamic>? levelInfo;

  const User({
    required this.id,
    required this.name,
    this.email = '',
    this.age = 0,
    this.rating = 0.0,
    this.ratingCount = 0,
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
    this.fcmTokens = const [],
    this.createdAt,
    this.creditsBalanceMinor = 0,
    this.isOnline = false,
    this.lastActive,
    this.teachingSeconds = 0,
    this.learningStreak = 0,
    this.highestLearningStreak = 0,
    this.levelInfo,
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

    // Handle Firestore Timestamps
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      // If it's a string, try to parse it
      if (value is String) return DateTime.tryParse(value);
      // In a real Flutter/Firebase app, we would use (value as Timestamp).toDate()
      // But since this model is also used for JSON/REST, we'll keep it flexible
      return null;
    }

    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      ratingCount: map['rating_count'] ?? 0,
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
      fcmTokens: List<String>.from(map['fcm_tokens'] ?? []),
      createdAt: parseDate(map['created_at']),
      creditsBalanceMinor: map['credits_balance_minor'] ?? 0,
      isOnline: map['is_online'] ?? false,
      lastActive: parseDate(map['last_active']),
      teachingSeconds: map['teaching_seconds'] ?? 0,
      learningStreak: map['learning_streak'] ?? 0,
      highestLearningStreak: map['highest_learning_streak'] ?? 0,
      levelInfo: map['level_info'],
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    double? rating,
    int? ratingCount,
    String? imageUrl,
    Skill? teaching,
    Skill? learning,
    List<Skill>? allSkills,
    String? bio,
    String? location,
    String? profession,
    List<PortfolioItem>? portfolio,
    String? matchId,
    String? matchStatus,
    String? matchPayerId,
    String? primaryCategory,
    String? expertiseLevel,
    List<String>? fcmTokens,
    DateTime? createdAt,
    int? creditsBalanceMinor,
    bool? isOnline,
    DateTime? lastActive,
    int? teachingSeconds,
    int? learningStreak,
    int? highestLearningStreak,
    Map<String, dynamic>? levelInfo,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      imageUrl: imageUrl ?? this.imageUrl,
      teaching: teaching ?? this.teaching,
      learning: learning ?? this.learning,
      allSkills: allSkills ?? this.allSkills,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      profession: profession ?? this.profession,
      portfolio: portfolio ?? this.portfolio,
      matchId: matchId ?? this.matchId,
      matchStatus: matchStatus ?? this.matchStatus,
      matchPayerId: matchPayerId ?? this.matchPayerId,
      primaryCategory: primaryCategory ?? this.primaryCategory,
      expertiseLevel: expertiseLevel ?? this.expertiseLevel,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      createdAt: createdAt ?? this.createdAt,
      creditsBalanceMinor: creditsBalanceMinor ?? this.creditsBalanceMinor,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
      teachingSeconds: teachingSeconds ?? this.teachingSeconds,
      learningStreak: learningStreak ?? this.learningStreak,
      highestLearningStreak: highestLearningStreak ?? this.highestLearningStreak,
      levelInfo: levelInfo ?? this.levelInfo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'rating': rating,
      'rating_count': ratingCount,
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
      'fcm_tokens': fcmTokens,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'credits_balance_minor': creditsBalanceMinor,
      'is_online': isOnline,
      if (lastActive != null) 'last_active': lastActive!.toIso8601String(),
      'teaching_seconds': teachingSeconds,
      'learning_streak': learningStreak,
      'highest_learning_streak': highestLearningStreak,
      'level_info': levelInfo,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    age,
    rating,
    ratingCount,
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
    fcmTokens,
    createdAt,
    creditsBalanceMinor,
    isOnline,
    lastActive,
    teachingSeconds,
    learningStreak,
    highestLearningStreak,
    levelInfo,
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
