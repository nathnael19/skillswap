import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/home/presentation/cubits/likes_state.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';

export 'likes_state.dart';

class LikesCubit extends Cubit<LikesState> {
  final HomeRepository _homeRepository;

  LikesCubit(this._homeRepository) : super(LikesInitial());

  Future<void> fetchLikes() async {
    emit(LikesLoading());
    try {
      final results = await Future.wait([
        _homeRepository.getLikesReceived(),
        _homeRepository.getSentLikes(),
        _homeRepository.getSentDislikes(),
      ]);

      final receivedResult = results[0];
      final sentResult = results[1];
      final passedResult = results[2];

      receivedResult.fold((l) => emit(LikesError(l.message)), (receivedList) {
        sentResult.fold((l) => emit(LikesError(l.message)), (sentList) {
          passedResult.fold(
            (l) => emit(LikesError(l.message)),
            (passedList) => emit(
              LikesLoaded(
                receivedLikes: receivedList,
                sentLikes: sentList,
                passedUsers: passedList,
              ),
            ),
          );
        });
      });
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
