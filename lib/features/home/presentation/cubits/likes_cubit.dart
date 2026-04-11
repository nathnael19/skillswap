import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';

abstract class LikesState extends Equatable {
  const LikesState();
  @override
  List<Object?> get props => [];
}

class LikesInitial extends LikesState {}
class LikesLoading extends LikesState {}
class LikesLoaded extends LikesState {
  final List<User> users;
  const LikesLoaded(this.users);
  @override
  List<Object?> get props => [users];
}
class LikesError extends LikesState {
  final String message;
  const LikesError(this.message);
  @override
  List<Object?> get props => [message];
}

class LikesCubit extends Cubit<LikesState> {
  final HomeRepository _homeRepository;

  LikesCubit(this._homeRepository) : super(LikesInitial());

  Future<void> fetchLikesReceived() async {
    emit(LikesLoading());
    final result = await _homeRepository.getLikesReceived();
    result.fold(
      (failure) => emit(LikesError(failure.message)),
      (users) => emit(LikesLoaded(users)),
    );
  }

  Future<void> likeBackUser(String targetId) async {
    final result = await _homeRepository.swipeUser(targetId: targetId, direction: 'like');
    result.fold(
      (failure) => null, // Handle error
      (isMatch) {
        // Remove the user from the likes list locally for snappy UI
        if (state is LikesLoaded) {
          final currentUsers = (state as LikesLoaded).users;
          final updatedUsers = currentUsers.where((u) => u.id != targetId).toList();
          emit(LikesLoaded(updatedUsers));
        }
      },
    );
  }
}
