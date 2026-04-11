import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/core/network/api_client.dart';
import 'package:skillswap/core/network/api_constants.dart';
import 'package:skillswap/features/home/domain/models/message_model.dart';
import 'package:skillswap/features/home/domain/repositories/chat_repository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ApiClient _apiClient;
  WebSocketChannel? _channel;

  ChatRepositoryImpl(this._apiClient);


  @override
  Future<Either<Failure, List<Message>>> getMessages(String matchId) async {
    try {
      final response = await _apiClient.get('${ApiConstants.messages}/$matchId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return right(data.map((m) => Message.fromMap(m)).toList());
      }
      return left(ServerFailure('Failed to fetch messages: ${response.body}'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Message> getMessagesStream(String matchId) async* {
    
    // Get fresh token for WebSocket
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return;

    final wsUrl = '${ApiConstants.wsBaseUrl}${ApiConstants.messages}/ws/$token';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    yield* _channel!.stream.map((event) {
      final data = jsonDecode(event);
      return Message.fromMap(data);
    }).where((message) => message.matchId == matchId);
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String matchId,
    required String content,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.messages,
        body: {
          'match_id': matchId,
          'content': content,
        },
      );
      if (response.statusCode == 200) {
        return right(Message.fromMap(jsonDecode(response.body)));
      }
      return left(ServerFailure('Failed to send message: ${response.body}'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
