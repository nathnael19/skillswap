import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';

abstract class MatchesState extends Equatable {
  const MatchesState();
  @override
  List<Object?> get props => [];
}

class MatchesInitial extends MatchesState {}
class MatchesLoading extends MatchesState {}
class MatchesLoaded extends MatchesState {
  final List<User> matches;
  const MatchesLoaded(this.matches);
  @override
  List<Object?> get props => [matches];
}
class MatchesError extends MatchesState {
  final String message;
  const MatchesError(this.message);
  @override
  List<Object?> get props => [message];
}

class MatchesCubit extends Cubit<MatchesState> {
  final HomeRepository _homeRepository;

  MatchesCubit(this._homeRepository) : super(MatchesInitial());

  Future<void> fetchMatches() async {
    emit(MatchesLoading());
    final result = await _homeRepository.getMatches();
    result.fold(
      (failure) => emit(MatchesError(failure.message)),
      (matches) => emit(MatchesLoaded(matches)),
    );
  }
}
