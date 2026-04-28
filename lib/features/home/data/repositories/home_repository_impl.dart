import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_database/firebase_database.dart';
import 'package:fpdart/fpdart.dart';
import 'package:skillswap/core/cache/local_cache_service.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/core/network/api_client.dart';
import 'package:skillswap/core/network/api_constants.dart';
import 'package:skillswap/features/home/domain/models/message_model.dart';
import 'package:skillswap/features/home/domain/models/review_model.dart';
import 'package:skillswap/features/home/domain/models/user_model.dart';
import 'package:skillswap/features/home/domain/repositories/home_repository.dart';
import 'package:skillswap/core/storage/storage_service.dart';
import 'dart:io';

class HomeRepositoryImpl implements HomeRepository {
  final ApiClient _apiClient;
  final FirebaseDatabase _db;
  final StorageService _storageService;
  final LocalCacheService _localCache;
  String? _cacheOwnerUid;
  final Duration _defaultTtl = const Duration(minutes: 3);
  final Map<String, _CacheEntry<User>> _userByIdCache = {};
  final Map<String, _CacheEntry<List<Review>>> _ratingsCache = {};
  _CacheEntry<User>? _meCache;
  _CacheEntry<List<User>>? _likesReceivedCache;

  HomeRepositoryImpl(
    this._apiClient,
    this._db,
    this._storageService,
    this._localCache,
  );

  String _activeUid() => FirebaseAuth.instance.currentUser?.uid ?? '';
  String _cacheKey(String suffix) => '${_activeUid()}:$suffix';

  void _invalidateCacheForUserSwitch() {
    final currentUid = _activeUid();
    if (_cacheOwnerUid == currentUid) return;
    _cacheOwnerUid = currentUid;
    _userByIdCache.clear();
    _ratingsCache.clear();
    _meCache = null;
    _likesReceivedCache = null;
  }

  T? _readCache<T>(_CacheEntry<T>? entry) {
    if (entry == null) return null;
    if (DateTime.now().isAfter(entry.expiresAt)) return null;
    return entry.value;
  }

  Future<List<T>?> _readCachedList<T>(
    String key,
    T Function(Map<String, dynamic>) parser,
  ) async {
    final cached = await _localCache.getList(key);
    if (cached == null) return null;
    return cached.map(parser).toList();
  }

  Future<void> _writeCachedList(String key, List<Map<String, dynamic>> value) {
    return _localCache.putList(key, value);
  }

  @override
  Stream<Message> getGlobalMessageStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _db
        .ref('global_updates/$uid')
        .onValue
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
      queryParams['mode'] = 'perfect_match';

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
    final cacheKey = _cacheKey('matches');
    try {
      final response = await _apiClient.get(ApiConstants.matches);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final matches = data.map((map) => Conversation.fromMap(map)).toList();
        await _writeCachedList(
          cacheKey,
          matches.map((conversation) => conversation.toMap()).toList(),
        );
        return right(matches);
      }
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to fetch matches',
      );
    } catch (e) {
      final cached = await _readCachedList(cacheKey, Conversation.fromMap);
      if (cached != null) return right(cached);
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getLikesReceived() async {
    final cacheKey = _cacheKey('likes_received');
    try {
      _invalidateCacheForUserSwitch();
      final cached = _readCache(_likesReceivedCache);
      if (cached != null) {
        return right(cached);
      }
      final response = await _apiClient.get(ApiConstants.likesReceived);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final users = data.map((m) => User.fromMap(m)).toList();
        await _writeCachedList(
          cacheKey,
          users.map((user) => user.toMap()).toList(),
        );
        _likesReceivedCache = _CacheEntry(
          value: users,
          expiresAt: DateTime.now().add(_defaultTtl),
        );
        return right(users);
      }
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to fetch likes',
      );
    } catch (e) {
      final cached = await _readCachedList(cacheKey, User.fromMap);
      if (cached != null) return right(cached);
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getSentLikes() async {
    final cacheKey = _cacheKey('likes_sent');
    try {
      final response = await _apiClient.get(ApiConstants.sentLikes);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final users = data.map((m) => User.fromMap(m)).toList();
        await _writeCachedList(
          cacheKey,
          users.map((user) => user.toMap()).toList(),
        );
        return right(users);
      }
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to fetch sent likes',
      );
    } catch (e) {
      final cached = await _readCachedList(cacheKey, User.fromMap);
      if (cached != null) return right(cached);
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getSentDislikes() async {
    final cacheKey = _cacheKey('likes_disliked');
    try {
      final response = await _apiClient.get(ApiConstants.sentDislikes);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final users = data.map((m) => User.fromMap(m)).toList();
        await _writeCachedList(
          cacheKey,
          users.map((user) => user.toMap()).toList(),
        );
        return right(users);
      }
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to fetch sent dislikes',
      );
    } catch (e) {
      final cached = await _readCachedList(cacheKey, User.fromMap);
      if (cached != null) return right(cached);
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCredits() async {
    final cacheKey = _cacheKey('wallet_credits');
    try {
      final response = await _apiClient.get(ApiConstants.credits);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        await _localCache.putMap(cacheKey, data);
        return right(data);
      }
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to fetch credits',
      );
    } catch (e) {
      final cached = await _localCache.getMap(cacheKey);
      if (cached != null) return right(cached);
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
  Future<Either<Failure, Map<String, dynamic>>> requestWithdrawal({
    required int amountMinor,
    required String method,
    required String accountNumber,
    required String accountName,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.withdraw,
        body: {
          'amount_minor': amountMinor,
          'method': method,
          'account_number': accountNumber,
          'account_name': accountName,
        },
      );
      if (response.statusCode == 200) {
        return right(jsonDecode(response.body) as Map<String, dynamic>);
      }
      return left(
        ServerFailure.fromResponse(
          response.statusCode,
          response.body,
          fallbackMessage: 'Failed to request withdrawal',
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

      final response = await _apiClient.post(ApiConstants.sessions, body: body);
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
    final cacheKey = _cacheKey('me');
    try {
      _invalidateCacheForUserSwitch();
      final cached = _readCache(_meCache);
      if (cached != null) {
        return right(cached);
      }
      final response = await _apiClient.get(ApiConstants.me);
      if (response.statusCode == 200) {
        final user = User.fromMap(jsonDecode(response.body));
        await _localCache.putMap(cacheKey, user.toMap());
        _meCache = _CacheEntry(
          value: user,
          expiresAt: DateTime.now().add(_defaultTtl),
        );
        return right(user);
      }
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to fetch user profile',
      );
    } catch (e) {
      final cached = await _localCache.getMap(cacheKey);
      if (cached != null) {
        final user = User.fromMap(cached);
        _meCache = _CacheEntry(
          value: user,
          expiresAt: DateTime.now().add(_defaultTtl),
        );
        return right(user);
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getUserById(String userId) async {
    final cacheKey = _cacheKey('user_$userId');
    try {
      _invalidateCacheForUserSwitch();
      final cached = _readCache(_userByIdCache[userId]);
      if (cached != null) {
        return right(cached);
      }
      final response = await _apiClient.get('${ApiConstants.userById}/$userId');
      if (response.statusCode == 200) {
        final user = User.fromMap(jsonDecode(response.body));
        await _localCache.putMap(cacheKey, user.toMap());
        _userByIdCache[userId] = _CacheEntry(
          value: user,
          expiresAt: DateTime.now().add(_defaultTtl),
        );
        return right(user);
      }
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to fetch user',
      );
    } catch (e) {
      final cached = await _localCache.getMap(cacheKey);
      if (cached != null) {
        final user = User.fromMap(cached);
        _userByIdCache[userId] = _CacheEntry(
          value: user,
          expiresAt: DateTime.now().add(_defaultTtl),
        );
        return right(user);
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Review>>> getRatings(String userId) async {
    final cacheKey = _cacheKey('ratings_$userId');
    try {
      _invalidateCacheForUserSwitch();
      final cached = _readCache(_ratingsCache[userId]);
      if (cached != null) {
        return right(cached);
      }
      final response = await _apiClient.get(
        '${ApiConstants.userRatings}/$userId',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final ratings = data.map((map) => Review.fromMap(map)).toList();
        await _writeCachedList(
          cacheKey,
          data.map((item) => Map<String, dynamic>.from(item as Map)).toList(),
        );
        _ratingsCache[userId] = _CacheEntry(
          value: ratings,
          expiresAt: DateTime.now().add(_defaultTtl),
        );
        return right(ratings);
      }
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to fetch ratings',
      );
    } catch (e) {
      final cached = await _readCachedList(cacheKey, Review.fromMap);
      if (cached != null) return right(cached);
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
        _invalidateCacheForUserSwitch();
        _ratingsCache.remove(targetId);
        await _localCache.remove(_cacheKey('ratings_$targetId'));
        await _localCache.remove(_cacheKey('user_$targetId'));
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
        final updated = User.fromMap(jsonDecode(response.body));
        await _localCache.putMap(_cacheKey('me'), updated.toMap());
        await _localCache.putMap(
          _cacheKey('user_${updated.id}'),
          updated.toMap(),
        );
        _meCache = _CacheEntry(
          value: updated,
          expiresAt: DateTime.now().add(_defaultTtl),
        );
        _userByIdCache[updated.id] = _CacheEntry(
          value: updated,
          expiresAt: DateTime.now().add(_defaultTtl),
        );
        return right(updated);
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

  @override
  Future<Either<Failure, String>> uploadImage(String filePath) async {
    try {
      final file = File(filePath);
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final url = await _storageService.uploadFile(path: fileName, file: file);

      return right(url);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}

class _CacheEntry<T> {
  final T value;
  final DateTime expiresAt;

  const _CacheEntry({required this.value, required this.expiresAt});
}
