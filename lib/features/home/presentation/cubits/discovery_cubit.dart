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
  final List<User> allUsers;
  final List<User> users;
  const DiscoveryLoaded({required this.allUsers, required this.users});
  
  @override
  List<Object?> get props => [allUsers, users];
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

  Future<void> fetchDiscoveryUsers({String? category, String? search}) async {
    emit(DiscoveryLoading());
    final result = await _homeRepository.getDiscoveryUsers(
      category: category,
      search: search,
    );
    result.fold(
      (failure) => emit(DiscoveryError(failure.message)),
      (users) => emit(DiscoveryLoaded(allUsers: users, users: users)),
    );
  }

  void filterDiscoveryUsers({
    required List<String> categories,
    required String expertise,
    required double minRating,
  }) {
    if (state is DiscoveryLoaded) {
      final loadedState = state as DiscoveryLoaded;
      
      final filteredList = loadedState.allUsers.where((user) {
        // 1. Category check (Multiple)
        bool matchesCategory = categories.isEmpty || 
            (user.teaching != null && categories.any((cat) => 
                user.teaching!.category.toLowerCase() == cat.toLowerCase()));
        
        // 2. Expertise check
        bool matchesExpertise = user.teaching != null && 
            user.teaching!.level.toLowerCase() == expertise.toLowerCase();
            
        // 3. Rating check
        bool matchesRating = user.rating >= minRating;

        return matchesCategory && matchesExpertise && matchesRating;
      }).toList();

      emit(DiscoveryLoaded(
        allUsers: loadedState.allUsers,
        users: filteredList,
      ));
    }
  }

  void resetFilters() {
    if (state is DiscoveryLoaded) {
      final loadedState = state as DiscoveryLoaded;
      emit(DiscoveryLoaded(
        allUsers: loadedState.allUsers,
        users: loadedState.allUsers,
      ));
    }
  }

  Future<void> swipeUser({required String targetId, required String direction}) async {
    final result = await _homeRepository.swipeUser(targetId: targetId, direction: direction);
    result.fold(
      (failure) => null,
      (isMatch) => null,
    );
  }
}
