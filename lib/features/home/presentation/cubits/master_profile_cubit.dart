import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/domain/models/review_model.dart';
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
  final List<Review> reviews;
  const MasterProfileLoaded(this.user, this.reviews);
  @override
  List<Object?> get props => [user, reviews];
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

    final results = await Future.wait([
      _homeRepository.getUserById(userId),
      _homeRepository.getRatings(userId),
    ]);

    final userResult = results[0] as Either<Failure, User>;
    final ratingsResult = results[1] as Either<Failure, List<Review>>;

    userResult.fold((failure) => emit(MasterProfileError(failure.message)), (
      user,
    ) {
      ratingsResult.fold(
        (failure) => emit(MasterProfileLoaded(user, const [])),
        (reviews) => emit(MasterProfileLoaded(user, reviews)),
      );
    });
  }
}
