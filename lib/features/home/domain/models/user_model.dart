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

  const User({
    required this.id,
    required this.name,
    required this.age,
    required this.rating,
    required this.imageUrl,
    required this.teaching,
    required this.learning,
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
  ];
}
