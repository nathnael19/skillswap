import 'package:equatable/equatable.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';

abstract class MatchesState extends Equatable {
  const MatchesState();
  @override
  List<Object?> get props => [];
}

class MatchesInitial extends MatchesState {}

class MatchesLoading extends MatchesState {}

class MatchesLoaded extends MatchesState {
  final List<Conversation> matches;
  final Map<String, bool> onlineStatuses;

  const MatchesLoaded(this.matches, {this.onlineStatuses = const {}});

  @override
  List<Object?> get props => [matches, onlineStatuses];
}

class MatchesError extends MatchesState {
  final String message;
  const MatchesError(this.message);
  @override
  List<Object?> get props => [message];
}
