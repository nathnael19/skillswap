import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final HomeRepository _homeRepository;

  ProfileCubit(this._homeRepository) : super(ProfileInitial());

  Future<void> fetchUserProfile() async {
    emit(ProfileLoading());
    final result = await _homeRepository.getMe();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  Future<void> updateUserProfile(User user) async {
    emit(ProfileLoading());
    final result = await _homeRepository.updateUserProfile(user);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (updatedUser) {
        emit(ProfileUpdateSuccess());
        emit(ProfileLoaded(updatedUser));
      },
    );
  }
}
