import 'package:equatable/equatable.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';

abstract class LikesState extends Equatable {
  const LikesState();
  @override
  List<Object?> get props => [];
}

class LikesInitial extends LikesState {}
class LikesLoading extends LikesState {}
class LikesLoaded extends LikesState {
  final List<User> receivedLikes;
  final List<User> sentLikes;
  final List<User> passedUsers;

  const LikesLoaded({
    required this.receivedLikes,
    required this.sentLikes,
    required this.passedUsers,
  });

  @override
  List<Object?> get props => [receivedLikes, sentLikes, passedUsers];
}

class LikesError extends LikesState {
  final String message;
  const LikesError(this.message);
  @override
  List<Object?> get props => [message];
}
