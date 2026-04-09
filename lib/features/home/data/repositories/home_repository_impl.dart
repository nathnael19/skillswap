import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/core/network/api_client.dart';
import 'package:skillswap/core/network/api_constants.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ApiClient _apiClient;

  HomeRepositoryImpl(this._apiClient);

  @override
  Future<Either<Failure, List<User>>> getDiscoveryUsers({String? category}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.discover,
        queryParams: category != null ? {'category': category} : null,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return right(data.map((map) => User.fromMap(map)).toList());
      }
      return left(ServerFailure('Failed to fetch discovery users: ${response.body}'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getMatches() async {
    try {
      final response = await _apiClient.get(ApiConstants.matches);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return right(data.map((map) => User.fromMap(map['user'])).toList());
      }
      return left(ServerFailure('Failed to fetch matches: ${response.body}'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCredits() async {
    try {
      final response = await _apiClient.get(ApiConstants.credits);
      if (response.statusCode == 200) {
        return right(jsonDecode(response.body));
      }
      return left(ServerFailure('Failed to fetch credits: ${response.body}'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> swipeUser({required String targetId, required String direction}) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.swipes,
        body: {'target_id': targetId, 'direction': direction},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return right(data['match_created'] ?? false);
      }
      return left(ServerFailure('Failed to swipe user: ${response.body}'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getMe() async {
    try {
      final response = await _apiClient.get(ApiConstants.me);
      if (response.statusCode == 200) {
        return right(User.fromMap(jsonDecode(response.body)));
      }
      return left(ServerFailure('Failed to fetch user profile: ${response.body}'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserProfile(User user) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.me,
        body: user.toMap(),
      );
      if (response.statusCode == 200) {
        return right(User.fromMap(jsonDecode(response.body)));
      }
      return left(ServerFailure('Failed to update user profile: ${response.body}'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
