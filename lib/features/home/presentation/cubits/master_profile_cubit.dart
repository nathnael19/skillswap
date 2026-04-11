import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';

abstract class MasterProfileState extends Equatable {
  const MasterProfileState();
  @override
  List<Object?> get props => [];
}

class MasterProfileInitial extends MasterProfileState {}
class MasterProfileLoading extends MasterProfileState {}
class MasterProfileLoaded extends MasterProfileState {
  final User user;
  const MasterProfileLoaded(this.user);
  @override
  List<Object?> get props => [user];
}
class MasterProfileError extends MasterProfileState {
  final String message;
  const MasterProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

class MasterProfileCubit extends Cubit<MasterProfileState> {
  final HomeRepository _homeRepository;

  MasterProfileCubit(this._homeRepository) : super(MasterProfileInitial());

  Future<void> fetchProfile(String userId) async {
    emit(MasterProfileLoading());
    final result = await _homeRepository.getUserById(userId);
    result.fold(
      (failure) => emit(MasterProfileError(failure.message)),
      (user) => emit(MasterProfileLoaded(user)),
    );
  }
}
