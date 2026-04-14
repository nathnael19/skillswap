import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/core/network/api_client.dart';
import 'package:skillswap/core/network/api_constants.dart';
import 'package:skillswap/features/home/domain/models/message_model.dart';
import 'package:skillswap/features/home/domain/models/review_model.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ApiClient _apiClient;
  WebSocketChannel? _channel;

  HomeRepositoryImpl(this._apiClient);

  @override
  Stream<Message> getGlobalMessageStream() async* {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return;

    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }

    final wsUrl = '${ApiConstants.wsBaseUrl}${ApiConstants.messages}/ws/$token';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    try {
      yield* _channel!.stream.map((event) {
        final data = jsonDecode(event);
        return Message.fromMap(data);
      });
    } finally {
      _channel?.sink.close();
      _channel = null;
    }
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
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.sessions,
        body: {
          'match_id': matchId,
          'scheduled_time': scheduledTime.toUtc().toIso8601String(),
        },
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
