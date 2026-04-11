import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';

abstract interface class HomeRepository {
  Future<Either<Failure, List<User>>> getDiscoveryUsers({String? category});
  Future<Either<Failure, List<User>>> getMatches();
  Future<Either<Failure, Map<String, dynamic>>> getCredits();
  Future<Either<Failure, bool>> swipeUser({
    required String targetId,
    required String direction,
  });
  Future<Either<Failure, User>> getMe();
  Future<Either<Failure, User>> updateUserProfile(User user);
}
