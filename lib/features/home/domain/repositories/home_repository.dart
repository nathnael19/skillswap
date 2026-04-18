import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/home/domain/models/message_model.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/domain/models/review_model.dart';

abstract interface class HomeRepository {
  Future<Either<Failure, List<User>>> getDiscoveryUsers({String? category, String? search});
  Future<Either<Failure, String>> initPaidChat(String targetId);
  Future<Either<Failure, Unit>> acceptMatch(String matchId);
  Future<Either<Failure, List<Conversation>>> getMatches();
  Stream<Message> getGlobalMessageStream();
  Future<Either<Failure, List<User>>> getLikesReceived();
  Future<Either<Failure, Map<String, dynamic>>> getCredits();
  Future<Either<Failure, Map<String, dynamic>>> createBillingCheckout();
  Future<Either<Failure, Map<String, dynamic>>> requestWithdrawal({
    required int amountMinor,
    required String method,
    required String accountNumber,
    required String accountName,
  });
  Future<Either<Failure, Map<String, dynamic>>> createSession({
    required String matchId,
    required DateTime scheduledTime,
    String? payerId,
  });
  Future<Either<Failure, Unit>> submitReview({
    required String sessionId,
    required String targetId,
    required double rating,
    required String comment,
  });
  Future<Either<Failure, Unit>> updateSessionStatus({
    required String sessionId,
    required String status,
  });
  Future<Either<Failure, bool>> swipeUser({
    required String targetId,
    required String direction,
  });
  Future<Either<Failure, List<User>>> getSentLikes();
  Future<Either<Failure, List<User>>> getSentDislikes();
  Future<Either<Failure, User>> getMe();
  Future<Either<Failure, User>> getUserById(String userId);
  Future<Either<Failure, List<Review>>> getRatings(String userId);
  Future<Either<Failure, User>> updateUserProfile(User user);
  Future<Either<Failure, String>> uploadImage(String filePath);
}
