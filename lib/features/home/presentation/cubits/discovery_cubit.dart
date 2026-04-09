import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';

abstract class DiscoveryState extends Equatable {
  const DiscoveryState();
  @override
  List<Object?> get props => [];
}

class DiscoveryInitial extends DiscoveryState {}
class DiscoveryLoading extends DiscoveryState {}
class DiscoveryLoaded extends DiscoveryState {
  final List<User> users;
  const DiscoveryLoaded(this.users);
  @override
  List<Object?> get props => [users];
}
class DiscoveryError extends DiscoveryState {
  final String message;
  const DiscoveryError(this.message);
  @override
  List<Object?> get props => [message];
}

class DiscoveryCubit extends Cubit<DiscoveryState> {
  final HomeRepository _homeRepository;

  DiscoveryCubit(this._homeRepository) : super(DiscoveryInitial());

  Future<void> fetchDiscoveryUsers({String? category}) async {
    emit(DiscoveryLoading());
    final result = await _homeRepository.getDiscoveryUsers(category: category);
    result.fold(
      (failure) => emit(DiscoveryError(failure.message)),
      (users) => emit(DiscoveryLoaded(users)),
    );
  }

  Future<void> swipeUser({required String targetId, required String direction}) async {
    // Optimistic UI could be implemented here, but for now we just call the repo
    final result = await _homeRepository.swipeUser(targetId: targetId, direction: direction);
    result.fold(
      (failure) => null, // Handle error silently or via state
      (isMatch) => null, // Handle match notification
    );
  }
}
