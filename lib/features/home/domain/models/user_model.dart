import 'package:equatable/equatable.dart';

class Skill extends Equatable {
  final String name;
  final String category;

  const Skill({required this.name, required this.category});

  @override
  List<Object?> get props => [name, category];
}

class User extends Equatable {
  final String id;
  final String name;
  final int age;
  final double rating;
  final String imageUrl;
  final Skill teaching;
  final Skill learning;
  final String bio;

  const User({
    required this.id,
    required this.name,
    required this.age,
    required this.rating,
    required this.imageUrl,
    required this.teaching,
    required this.learning,
    this.bio = '',
  });

  @override
  List<Object?> get props => [
    id,
    name,
    age,
    rating,
    imageUrl,
    teaching,
    learning,
    bio,
  ];
}

class Conversation extends Equatable {
  final User user;
  final String lastMessage;
  final String timestamp;
  final bool isOnline;
  final bool hasUnread;
  final String skillTag;

  const Conversation({
    required this.user,
    required this.lastMessage,
    required this.timestamp,
    this.isOnline = false,
    this.hasUnread = false,
    required this.skillTag,
  });

  @override
  List<Object?> get props => [user, lastMessage, timestamp, isOnline, hasUnread, skillTag];
}
