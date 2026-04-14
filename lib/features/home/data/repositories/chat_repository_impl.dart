import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/core/network/api_client.dart';
import 'package:skillswap/core/network/api_constants.dart';
import 'package:skillswap/features/home/domain/models/message_model.dart';
import 'package:skillswap/features/home/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ApiClient _apiClient;
  final FirebaseDatabase _db;

  // Global stream for all incoming RTDB events (Messages & Signaling)
  final StreamController<dynamic> _globalStreamController = StreamController<dynamic>.broadcast();
  
  StreamSubscription? _signalingSubscription;
  final Map<String, StreamSubscription> _matchSubscriptions = {};
  String? _currentUserUid;

  ChatRepositoryImpl(this._apiClient, this._db) {
    _initSignalingListener();
  }

  void _initSignalingListener() {
    _currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (_currentUserUid == null) return;

    _signalingSubscription?.cancel();
    // Listen for signaling events addressed to me
    _signalingSubscription = _db.ref('signaling/$_currentUserUid').onChildAdded.listen((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        final Map<String, dynamic> signalingData = Map<String, dynamic>.from(data);
        _globalStreamController.add(signalingData);
        // Remove signal after processing to keep RTDB clean (one-time signals)
        event.snapshot.ref.remove();
      }
    });
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
    // Re-init signaling listener if it wasn't set up at construction time
    // (e.g. if the user wasn't logged in when the repo was first instantiated)
    if (_signalingSubscription == null) {
      _initSignalingListener();
    }

    // Check if we are already listening to this match
    if (!_matchSubscriptions.containsKey(matchId)) {
      _matchSubscriptions[matchId] = _db.ref('messages/$matchId').onChildAdded.listen((event) {
        final data = event.snapshot.value;
        if (data is Map) {
          final msg = Message.fromMap(Map<String, dynamic>.from(data));
          _globalStreamController.add(msg);
        }
      });
    }
    
    // Return a stream that filters for this specific match or WebRTC signaling
    return _globalStreamController.stream.where((event) {
      if (event is Message) {
        return event.matchId == matchId;
      }
      if (event is Map<String, dynamic> && event['type'] == 'webrtc_signaling') {
        return true; 
      }
      return false;
    });
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String matchId,
    required String content,
  }) async {
    try {
      // We still call the backend to ensure Firestore archiving and metadata updates
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
    final targetUid = payload['target_uid'];
    if (targetUid == null) return;

    // Stamp sender info
    final senderUid = FirebaseAuth.instance.currentUser?.uid;
    payload['sender_id'] = senderUid;

    // Push to target's signaling queue in RTDB
    _db.ref('signaling/$targetUid').push().set(payload);
  }

  void dispose() {
    _signalingSubscription?.cancel();
    for (var sub in _matchSubscriptions.values) {
      sub.cancel();
    }
    _globalStreamController.close();
  }
}
