import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/cache/local_cache_service.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/core/network/api_client.dart';
import 'package:skillswap/core/network/api_constants.dart';
import 'package:skillswap/features/home/domain/models/message_model.dart';
import 'package:skillswap/features/home/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ApiClient _apiClient;
  final FirebaseDatabase _db;
  final LocalCacheService _localCache;
  static const Duration _chatCacheTtl = Duration(minutes: 2);

  // Global stream for all incoming RTDB events (Messages)
  final StreamController<dynamic> _globalStreamController =
      StreamController<dynamic>.broadcast();
  final Map<String, List<StreamSubscription>> _matchSubscriptions = {};

  ChatRepositoryImpl(this._apiClient, this._db, this._localCache);

  String _cacheKey(String matchId) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    return '$uid:chat_messages_$matchId';
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(String matchId) async {
    final cacheKey = _cacheKey(matchId);
    try {
      final response = await _apiClient.get(
        '${ApiConstants.messages}/$matchId',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final messages = data.map((m) => Message.fromMap(m)).toList();
        await _localCache.putList(
          cacheKey,
          messages.map((message) => message.toMap()).toList(),
        );
        return right(messages);
      }
      throw ServerFailure('Failed to fetch messages: ${response.body}');
    } catch (e) {
      final cached = await _localCache.getList(cacheKey, maxAge: _chatCacheTtl);
      if (cached != null) {
        return right(cached.map(Message.fromMap).toList());
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<dynamic> getMessagesStream(String matchId) {
    // Check if we are already listening to this match
    if (!_matchSubscriptions.containsKey(matchId)) {
      final nodeRef = _db.ref('messages/$matchId');

      final addedSub = nodeRef.onChildAdded.listen((event) {
        final data = event.snapshot.value;
        if (data is Map) {
          final msg = Message.fromMap(Map<String, dynamic>.from(data));
          unawaited(_upsertCachedMessage(matchId, msg));
          _globalStreamController.add(msg);
        }
      });

      final changedSub = nodeRef.onChildChanged.listen((event) {
        final data = event.snapshot.value;
        if (data is Map) {
          final msg = Message.fromMap(Map<String, dynamic>.from(data));
          // Emit updated message (e.g. isRead changed)
          unawaited(_upsertCachedMessage(matchId, msg));
          _globalStreamController.add(msg);
        }
      });

      _matchSubscriptions[matchId] = [addedSub, changedSub];
    }

    // Return a stream that filters for this specific match only
    return _globalStreamController.stream.where((event) {
      if (event is Message) {
        return event.matchId == matchId;
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
        body: {'match_id': matchId, 'content': content},
      );
      if (response.statusCode == 200) {
        final message = Message.fromMap(jsonDecode(response.body));
        await _upsertCachedMessage(matchId, message);
        return right(message);
      }
      return left(ServerFailure('Failed to send message: ${response.body}'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markMessagesAsRead(String matchId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.messages}/read/$matchId',
      );
      if (response.statusCode == 200) {
        return right(unit);
      }
      return left(ServerFailure('Failed to mark as read: ${response.body}'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  void dispose() {
    for (var subs in _matchSubscriptions.values) {
      for (var s in subs) {
        s.cancel();
      }
    }
    _globalStreamController.close();
  }

  Future<void> _upsertCachedMessage(String matchId, Message message) async {
    final cacheKey = _cacheKey(matchId);
    final cached =
        await _localCache.getList(cacheKey, maxAge: _chatCacheTtl) ?? const [];
    final messages = cached.map(Message.fromMap).toList();
    final index = messages.indexWhere((item) => item.id == message.id);
    if (index == -1) {
      messages.add(message);
    } else {
      messages[index] = message;
    }
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    await _localCache.putList(
      cacheKey,
      messages.map((item) => item.toMap()).toList(),
    );
  }
}
