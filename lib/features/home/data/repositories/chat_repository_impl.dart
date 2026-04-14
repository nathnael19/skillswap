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
  final Map<String, List<StreamSubscription>> _matchSubscriptions = {};
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
    if (_signalingSubscription == null) {
      _initSignalingListener();
    }

    // Check if we are already listening to this match
    if (!_matchSubscriptions.containsKey(matchId)) {
      final nodeRef = _db.ref('messages/$matchId');
      
      final addedSub = nodeRef.onChildAdded.listen((event) {
        final data = event.snapshot.value;
        if (data is Map) {
          final msg = Message.fromMap(Map<String, dynamic>.from(data));
          _globalStreamController.add(msg);
        }
      });

      final changedSub = nodeRef.onChildChanged.listen((event) {
        final data = event.snapshot.value;
        if (data is Map) {
          final msg = Message.fromMap(Map<String, dynamic>.from(data));
          // Emit updated message (e.g. isRead changed)
          _globalStreamController.add(msg);
        }
      });

      _matchSubscriptions[matchId] = [addedSub, changedSub];
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
  Future<Either<Failure, Unit>> markMessagesAsRead(String matchId) async {
    try {
      final response = await _apiClient.post('${ApiConstants.messages}/read/$matchId');
      if (response.statusCode == 200) {
        return right(unit);
      }
      return left(ServerFailure('Failed to mark as read: ${response.body}'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  void sendSignalingMessage(Map<String, dynamic> payload) {
    final targetUid = payload['target_uid'];
    if (targetUid == null) return;

    final senderUid = FirebaseAuth.instance.currentUser?.uid;
    payload['sender_id'] = senderUid;

    _db.ref('signaling/$targetUid').push().set(payload);
  }

  void dispose() {
    _signalingSubscription?.cancel();
    for (var subs in _matchSubscriptions.values) {
      for (var s in subs) {
        s.cancel();
      }
    }
    _globalStreamController.close();
  }
}
