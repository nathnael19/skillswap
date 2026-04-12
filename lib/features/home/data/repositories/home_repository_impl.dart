import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/core/network/api_client.dart';
import 'package:skillswap/core/network/api_constants.dart';
import 'package:skillswap/features/home/domain/models/message_model.dart';
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

    final wsUrl = '${ApiConstants.wsBaseUrl}${ApiConstants.messages}/ws/$token';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    yield* _channel!.stream.map((event) {
      final data = jsonDecode(event);
      return Message.fromMap(data);
    });
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
        ServerFailure('Failed to fetch discovery users: ${response.body}'),
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
      return left(ServerFailure('Failed to fetch matches: ${response.body}'));
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
      return left(ServerFailure('Failed to fetch likes: ${response.body}'));
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
        ServerFailure('Failed to fetch sent likes: ${response.body}'),
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
        ServerFailure('Failed to fetch sent dislikes: ${response.body}'),
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
      return left(ServerFailure('Failed to fetch credits: ${response.body}'));
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
      return left(
        ServerFailure('Failed to fetch user profile: ${response.body}'),
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
      return left(ServerFailure('Failed to fetch user: ${response.body}'));
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
        ServerFailure('Failed to update user profile: ${response.body}'),
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
