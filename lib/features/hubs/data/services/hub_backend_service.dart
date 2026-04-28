import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillswap/core/cache/local_cache_service.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/core/network/api_client.dart';
import 'package:skillswap/core/network/api_constants.dart';
import 'package:skillswap/features/hubs/data/models/hub_message_model.dart';
import 'package:skillswap/features/hubs/data/models/hub_model.dart';

class HubBackendService {
  final ApiClient _apiClient;
  final LocalCacheService _localCache;

  HubBackendService(this._apiClient, this._localCache);

  String _scopeKey(String suffix) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    return '$uid:$suffix';
  }

  Future<List<Hub>> listHubs() async {
    final cacheKey = _scopeKey('hub_list');
    try {
      final response = await _apiClient.get(ApiConstants.hubs);
      if (response.statusCode != 200) {
        throw ServerFailure.fromResponse(
          response.statusCode,
          response.body,
          fallbackMessage: 'Failed to fetch hubs',
        );
      }
      final data = jsonDecode(response.body) as List<dynamic>;
      final hubs = data
          .map((item) => Hub.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
      await _localCache.putList(
        cacheKey,
        hubs
            .map(
              (hub) => {
                'id': hub.id,
                'name': hub.name,
                'slug': hub.slug,
                'description': hub.description,
                'category': hub.category,
                'is_private': hub.isPrivate,
                'is_member': hub.isMember,
                'member_count': hub.memberCount,
              },
            )
            .toList(),
      );
      return hubs;
    } catch (e) {
      final cached = await _localCache.getList(cacheKey);
      if (cached != null) {
        return cached.map(Hub.fromMap).toList();
      }
      rethrow;
    }
  }

  Future<String> createHub({
    required String name,
    required String slug,
    required String description,
    required String category,
    bool isPrivate = false,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.hubs,
      body: {
        'name': name,
        'slug': slug,
        'description': description,
        'category': category,
        'is_private': isPrivate,
      },
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to create hub',
      );
    }
    final data = jsonDecode(response.body);
    return data['id'];
  }

  Future<void> joinHub(String hubId) async {
    final response = await _apiClient.post(
      '${ApiConstants.hubs}/$hubId/join',
      body: <String, dynamic>{},
    );
    if (response.statusCode != 200) {
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to join hub',
      );
    }
    await _localCache.remove(_scopeKey('hub_list'));
  }

  Future<void> leaveHub(String hubId) async {
    final response = await _apiClient.post(
      '${ApiConstants.hubs}/$hubId/leave',
      body: <String, dynamic>{},
    );
    if (response.statusCode != 200) {
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to leave hub',
      );
    }
    await _localCache.remove(_scopeKey('hub_list'));
  }

  Future<List<HubMessage>> getMessages(String hubId) async {
    final cacheKey = _scopeKey('hub_messages_$hubId');
    try {
      final response = await _apiClient.get(
        '${ApiConstants.hubs}/$hubId/messages',
      );
      if (response.statusCode != 200) {
        throw ServerFailure.fromResponse(
          response.statusCode,
          response.body,
          fallbackMessage: 'Failed to fetch hub messages',
        );
      }
      final data = jsonDecode(response.body) as List<dynamic>;
      final messages = data
          .map(
            (item) =>
                HubMessage.fromMap(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
      await _localCache.putList(
        cacheKey,
        messages
            .map(
              (message) => {
                'id': message.id,
                'sender_id': message.senderId,
                'text': message.text,
                'created_at': message.createdAt.toIso8601String(),
              },
            )
            .toList(),
      );
      return messages;
    } catch (e) {
      final cached = await _localCache.getList(cacheKey);
      if (cached != null) {
        return cached.map(HubMessage.fromMap).toList();
      }
      rethrow;
    }
  }

  Future<void> sendMessage(String hubId, String text) async {
    final response = await _apiClient.post(
      '${ApiConstants.hubs}/$hubId/messages',
      body: {'text': text},
    );
    if (response.statusCode != 200) {
      throw ServerFailure.fromResponse(
        response.statusCode,
        response.body,
        fallbackMessage: 'Failed to send hub message',
      );
    }
  }
}
