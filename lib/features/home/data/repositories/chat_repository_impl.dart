import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/core/network/api_client.dart';
import 'package:skillswap/core/network/api_constants.dart';
import 'package:skillswap/features/home/domain/models/message_model.dart';
import 'package:skillswap/features/home/domain/repositories/chat_repository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ApiClient _apiClient;
  WebSocketChannel? _channel;

  // Global stream for all incoming WebSocket events
  final StreamController<dynamic> _globalStreamController = StreamController<dynamic>.broadcast();
  bool _isConnecting = false;
  String? _currentUserUid;

  ChatRepositoryImpl(this._apiClient) {
    // Start connection as soon as created, or on first request
    _ensureConnected();
  }

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
  Stream<dynamic> getMessagesStream(String matchId) {
    _ensureConnected();
    
    // Return a stream that filters for this specific match or WebRTC signaling
    return _globalStreamController.stream.where((event) {
      if (event is Message) {
        return event.matchId == matchId;
      }
      if (event is Map<String, dynamic> && event['type'] == 'webrtc_signaling') {
        // We keep signaling events here; ChatCubit will filter for the peerId
        return true; 
      }
      return false;
    });
  }

  Future<void> _ensureConnected() async {
    if (_isConnecting) return;
    
    // If channel is fine, just return
    if (_channel != null && _currentUserUid == FirebaseAuth.instance.currentUser?.uid) {
      return;
    }

    _isConnecting = true;
    _currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
      if (token == null) {
        _isConnecting = false;
        return;
      }

      final wsUrl = '${ApiConstants.wsBaseUrl}${ApiConstants.messages}/ws/$token';
      debugPrint('[WS-REPO] Connecting to $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel!.stream.listen(
        (event) {
          try {
            final data = jsonDecode(event as String);
            if (data['type'] == 'webrtc_signaling') {
              _globalStreamController.add(data);
            } else {
              final msg = Message.fromMap(data);
              _globalStreamController.add(msg);
            }
          } catch (e) {
            debugPrint('[WS-REPO] Parse error: $e');
          }
        },
        onError: (e) {
          debugPrint('[WS-REPO] Error: $e — reconnecting in 3s');
          _isConnecting = false;
          _channel = null;
          Future.delayed(const Duration(seconds: 3), _ensureConnected);
        },
        onDone: () {
          debugPrint('[WS-REPO] Closed — reconnecting in 3s');
          _isConnecting = false;
          _channel = null;
          Future.delayed(const Duration(seconds: 3), _ensureConnected);
        },
        cancelOnError: false,
      );

      _isConnecting = false;
    } catch (e) {
      debugPrint('[WS-REPO] Failed: $e — retrying in 5s');
      _isConnecting = false;
      _channel = null;
      Future.delayed(const Duration(seconds: 5), _ensureConnected);
    }
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

  @override
  void sendSignalingMessage(Map<String, dynamic> payload) {
    if (_channel == null) {
      debugPrint('[WS-REPO] Cannot send — connecting...');
      _ensureConnected().then((_) {
        _channel?.sink.add(jsonEncode(payload));
      });
      return;
    }
    _channel!.sink.add(jsonEncode(payload));
  }

  void dispose() {
    _channel?.sink.close();
    _globalStreamController.close();
  }
}
