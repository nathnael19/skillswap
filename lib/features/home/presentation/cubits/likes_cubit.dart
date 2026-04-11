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

class LikesCubit extends Cubit<LikesState> {
  final HomeRepository _homeRepository;

  LikesCubit(this._homeRepository) : super(LikesInitial());

  Future<void> fetchLikes() async {
    emit(LikesLoading());
    try {
      final receivedResult = await _homeRepository.getLikesReceived();
      final sentResult = await _homeRepository.getSentLikes();
      final passedResult = await _homeRepository.getSentDislikes();

      receivedResult.fold(
        (l) => emit(LikesError(l.message)),
        (receivedList) {
          sentResult.fold(
            (l) => emit(LikesError(l.message)),
            (sentList) {
              passedResult.fold(
                (l) => emit(LikesError(l.message)),
                (passedList) => emit(LikesLoaded(
                  receivedLikes: receivedList,
                  sentLikes: sentList,
                  passedUsers: passedList,
                )),
              );
            },
          );
        },
      );
    } catch (e) {
      emit(LikesError(e.toString()));
    }
  }

  Future<void> likeBackUser(String userId) async {
    await _homeRepository.swipeUser(targetId: userId, direction: 'like');
    fetchLikes();
  }

  Future<void> undoLike(String userId) async {
    await _homeRepository.swipeUser(targetId: userId, direction: 'dislike');
    fetchLikes();
  }

  Future<void> fetchLikesReceived() => fetchLikes();
}
