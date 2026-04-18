import 'package:equatable/equatable.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';

abstract class DiscoveryState extends Equatable {
  const DiscoveryState();
  @override
  List<Object?> get props => [];
}

class DiscoveryInitial extends DiscoveryState {}

class DiscoveryLoading extends DiscoveryState {}

class DiscoveryLoaded extends DiscoveryState {
  final List<User> allUsers;
  final List<User> users;

  const DiscoveryLoaded({required this.allUsers, required this.users});

  @override
  List<Object?> get props => [allUsers, users];
}

class DiscoveryFiltered extends DiscoveryLoaded {
  const DiscoveryFiltered({required super.allUsers, required super.users});
}

class DiscoveryError extends DiscoveryState {
  final String message;
  const DiscoveryError(this.message);
  @override
  List<Object?> get props => [message];
}

class DiscoverySwipeError extends DiscoveryLoaded {
  final String errorMessage;
  const DiscoverySwipeError({
    required super.allUsers,
    required super.users,
    required this.errorMessage,
  });
  @override
  List<Object?> get props => [allUsers, users, errorMessage];
}
