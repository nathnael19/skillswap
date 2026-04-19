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

    User userToUpdate = user;

    // Check if imageUrl is a local path (from ImagePicker)
    if (user.imageUrl.isNotEmpty &&
        !user.imageUrl.startsWith('http') &&
        !user.imageUrl.startsWith('assets/')) {
      final uploadResult = await _homeRepository.uploadImage(user.imageUrl);

      bool uploadFailed = false;
      uploadResult.fold(
        (failure) {
          emit(
            ProfileError(
              'Failed to upload profile picture: ${failure.message}',
            ),
          );
          uploadFailed = true;
        },
        (remoteUrl) {
          userToUpdate = user.copyWith(imageUrl: remoteUrl);
        },
      );

      if (uploadFailed) return;
    }

    final result = await _homeRepository.updateUserProfile(userToUpdate);
    result.fold((failure) => emit(ProfileError(failure.message)), (
      updatedUser,
    ) {
      emit(ProfileUpdateSuccess());
      emit(ProfileLoaded(updatedUser));
    });
  }
}
