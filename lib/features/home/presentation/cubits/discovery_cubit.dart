import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/presentation/cubits/discovery_state.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';

export 'discovery_state.dart';

class DiscoveryCubit extends HydratedCubit<DiscoveryState> {
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
        bool matchesCategory =
            categories.isEmpty ||
            (user.teaching != null &&
                categories.any(
                  (cat) =>
                      user.teaching!.category.toLowerCase() ==
                      cat.toLowerCase(),
                ));

        // 2. Expertise check
        bool matchesExpertise =
            expertise.toLowerCase() == 'all' ||
            (user.teaching != null &&
                user.teaching!.level.toLowerCase() == expertise.toLowerCase());

        // 3. Rating check
        bool matchesRating = user.rating >= minRating;

        return matchesCategory && matchesExpertise && matchesRating;
      }).toList();

      emit(
        DiscoveryFiltered(allUsers: loadedState.allUsers, users: filteredList),
      );
    }
  }

  void resetFilters() {
    if (state is DiscoveryLoaded) {
      final loadedState = state as DiscoveryLoaded;
      emit(
        DiscoveryLoaded(
          allUsers: loadedState.allUsers,
          users: loadedState.allUsers,
        ),
      );
    }
  }

  Future<void> swipeUser({
    required String targetId,
    required String direction,
  }) async {
    final currentState = state;
    final result = await _homeRepository.swipeUser(
      targetId: targetId,
      direction: direction,
    );
    result.fold((failure) {
      if (currentState is DiscoveryLoaded) {
        emit(
          DiscoverySwipeError(
            allUsers: currentState.allUsers,
            users: currentState.users,
            errorMessage: failure.message,
          ),
        );
      }
    }, (isMatch) => null);
  }

  @override
  DiscoveryState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['status'] == 'DiscoveryLoaded' || json['status'] == 'DiscoveryFiltered') {
        final allUsersRaw = json['allUsers'] as List<dynamic>;
        final usersRaw = json['users'] as List<dynamic>;

        final allUsers = allUsersRaw.map((e) => User.fromMap(e as Map<String, dynamic>)).toList();
        final users = usersRaw.map((e) => User.fromMap(e as Map<String, dynamic>)).toList();

        if (json['status'] == 'DiscoveryFiltered') {
          return DiscoveryFiltered(allUsers: allUsers, users: users);
        }
        return DiscoveryLoaded(allUsers: allUsers, users: users);
      }
    } catch (_) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(DiscoveryState state) {
    if (state is DiscoveryLoaded) {
      return {
        'status': state is DiscoveryFiltered ? 'DiscoveryFiltered' : 'DiscoveryLoaded',
        'allUsers': state.allUsers.map((u) => u.toMap()).toList(),
        'users': state.users.map((u) => u.toMap()).toList(),
      };
    }
    return null;
  }
}
