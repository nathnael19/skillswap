import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_database/firebase_database.dart';
import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/core/network/api_client.dart';
import 'package:skillswap/core/network/api_constants.dart';
import 'package:skillswap/features/home/domain/models/message_model.dart';
import 'package:skillswap/features/home/domain/models/review_model.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ApiClient _apiClient;
  final FirebaseDatabase _db;

  HomeRepositoryImpl(this._apiClient, this._db);

  @override
  Stream<Message> getGlobalMessageStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _db.ref('global_updates/$uid').onValue
        .where((event) => event.snapshot.value != null)
        .map((event) {
          final data = event.snapshot.value;
          if (data is Map) {
            return Message.fromMap(Map<String, dynamic>.from(data));
          }
          return null;
        })
        .where((msg) => msg != null)
        .cast<Message>();
  }

  @override
  Future<Either<Failure, String>> initPaidChat(String targetId) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.initPaidChat,
        body: {'target_id': targetId},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return right(data['match_id']);
      }
      return left(
        ServerFailure.fromResponse(
          response.statusCode,
          response.body,
          fallbackMessage: 'Failed to initialize paid chat',
        ),
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> acceptMatch(String matchId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.acceptMatch}/$matchId/accept',
        body: {},
      );
      if (response.statusCode == 200) {
        return right(unit);
      }
      return left(
        ServerFailure.fromResponse(
          response.statusCode,
          response.body,
          fallbackMessage: 'Failed to accept connection',
        ),
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getDiscoveryUsers({
    String? category,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiClient.get(
        ApiConstants.discover,
        queryParams: queryParams.isEmpty ? null : queryParams,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return right(data.map((map) => User.fromMap(map)).toList());
      }
      return left(
        ServerFailure.fromResponse(
          response.statusCode,
          response.body,
          fallbackMessage: 'Failed to fetch discovery users',
        ),
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Conversation>>> getMatches() async {
    try {
      final response = await _apiClient.get(ApiConstants.matches);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return right(data.map((map) => Conversation.fromMap(map)).toList());
      }
      return left(
        ServerFailure.fromResponse(
          response.statusCode,
          response.body,
          fallbackMessage: 'Failed to fetch matches',
        ),
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getLikesReceived() async {
    try {
      final response = await _apiClient.get(ApiConstants.likesReceived);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return right(data.map((m) => User.fromMap(m)).toList());
      }
      return left(
        ServerFailure.fromResponse(
          response.statusCode,
          response.body,
          fallbackMessage: 'Failed to fetch likes',
        ),
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getSentLikes() async {
    try {
      final response = await _apiClient.get(ApiConstants.sentLikes);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return right(data.map((m) => User.fromMap(m)).toList());
      }
      return left(
        ServerFailure.fromResponse(
          response.statusCode,
          response.body,
          fallbackMessage: 'Failed to fetch sent likes',
        ),
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getSentDislikes() async {
    try {
      final response = await _apiClient.get(ApiConstants.sentDislikes);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return right(data.map((m) => User.fromMap(m)).toList());
      }
      return left(
        ServerFailure.fromResponse(
          response.statusCode,
          response.body,
          fallbackMessage: 'Failed to fetch sent dislikes',
        ),
      );
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
      return left(
        ServerFailure.fromResponse(
          response.statusCode,
          response.body,
          fallbackMessage: 'Failed to fetch credits',
        ),
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createBillingCheckout() async {
    try {
      final response = await _apiClient.post(
        ApiConstants.billingCheckout,
        body: <String, dynamic>{},
      );
      if (response.statusCode == 200) {
        return right(jsonDecode(response.body) as Map<String, dynamic>);
      }
      return left(
        ServerFailure.fromResponse(
          response.statusCode,
          response.body,
          fallbackMessage: 'Failed to start checkout',
        ),
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createSession({
    required String matchId,
    required DateTime scheduledTime,
    String? payerId,
  }) async {
    try {
      final body = {
        'match_id': matchId,
        'scheduled_time': scheduledTime.toUtc().toIso8601String(),
      };
      if (payerId != null) {
        body['payer_id'] = payerId;
      }
      
      final response = await _apiClient.post(
        ApiConstants.sessions,
        body: body,
      );
      if (response.statusCode == 200) {
        return right(jsonDecode(response.body) as Map<String, dynamic>);
      }
      return left(
        ServerFailure.fromResponse(
          response.statusCode,
          response.body,
          fallbackMessage: 'Failed to create session',
        ),
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateSessionStatus({
    required String sessionId,
    required String status,
  }) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConstants.sessions}/$sessionId',
        body: {'status': status},
      );
      if (response.statusCode == 200) {
        return right(unit);
      }
      return left(
        ServerFailure.fromResponse(
          response.statusCode,
          response.body,
          fallbackMessage: 'Failed to update session',
        ),
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> swipeUser({
    required String targetId,
    required String direction,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.swipes,
        body: {'target_id': targetId, 'direction': direction},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return right(data['match_created'] ?? false);
      }
      return left(
        ServerFailure.fromResponse(
          response.statusCode,
          response.body,
          fallbackMessage: 'Failed to swipe user',
        ),
      );
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
      return left(
        ServerFailure.fromResponse(
          response.statusCode,
          response.body,
          fallbackMessage: 'Failed to fetch user profile',
        ),
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getUserById(String userId) async {
    try {
      final response = await _apiClient.get('${ApiConstants.userById}/$userId');
      if (response.statusCode == 200) {
        return right(User.fromMap(jsonDecode(response.body)));
      }
      return left(
        ServerFailure.fromResponse(
          response.statusCode,
          response.body,
          fallbackMessage: 'Failed to fetch user',
        ),
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Review>>> getRatings(String userId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.userRatings}/$userId',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return right(data.map((map) => Review.fromMap(map)).toList());
      }
      return left(
        ServerFailure.fromResponse(
          response.statusCode,
          response.body,
          fallbackMessage: 'Failed to fetch ratings',
        ),
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> submitReview({
    required String sessionId,
    required String targetId,
    required double rating,
    required String comment,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.ratings,
        body: {
          'session_id': sessionId,
          'target_id': targetId,
          'rating': rating,
          'comment': comment,
        },
      );
      if (response.statusCode == 200) {
        return right(unit);
      }
      return left(
        ServerFailure.fromResponse(
          response.statusCode,
          response.body,
          fallbackMessage: 'Failed to submit review',
        ),
      );
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
      return left(
        ServerFailure.fromResponse(
          response.statusCode,
          response.body,
          fallbackMessage: 'Failed to update user profile',
        ),
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
